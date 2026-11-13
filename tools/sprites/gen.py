import numpy as np, json
from pack import frame_layers, best_pack, best_pack_smart
from moves import MOVES
GROUP_A=[0,1,2]; GROUP_B=[5,6,7]
def enc4(t):
    b=bytearray()
    for y in range(8):
        p0=p1=0
        for x in range(8):
            v=t[y,x]; p0|=((v>>0)&1)<<(7-x); p1|=((v>>1)&1)<<(7-x)
        b+=bytes([p0,p1])
    for y in range(8):
        p2=p3=0
        for x in range(8):
            v=t[y,x]; p2|=((v>>2)&1)<<(7-x); p3|=((v>>3)&1)<<(7-x)
        b+=bytes([p2,p3])
    return bytes(b)
class Alloc:
    def __init__(s): s.occ={}; s.data={}
    def free(s,r,c): return (r,c) not in s.occ
    def put16(s,rows,t16):
        for r in rows:
            if r+1 not in rows: continue
            for c in range(0,15):
                if all(s.free(rr,cc) for rr in (r,r+1) for cc in (c,c+1)):
                    for dy,rr in enumerate((r,r+1)):
                        for dx,cc in enumerate((c,c+1)):
                            s.occ[(rr,cc)]=1; s.data[(rr,cc)]=t16[dy*8:dy*8+8,dx*8:dx*8+8]
                    return r*16+c
        return None
    def put8(s,rows,t):
        for r in rows:
            for c in range(16):
                if s.free(r,c): s.occ[(r,c)]=1; s.data[(r,c)]=t; return r*16+c
        return None
def flips(t): return [(t,0),(t[:,::-1],0x40),(t[::-1,:],0x80),(t[::-1,::-1],0xC0)]
def build_step_split(body_p,arc_p):
    res=[]
    for pieces,rows in ((body_p,GROUP_A),(arc_p,GROUP_B)):
        al=Alloc(); known={}; ents=[]
        if rows is GROUP_B:
            for c in range(11,16): al.occ[(7,c)]=1   # $7B vazio reservado; $7C-$7F particulas da carga
            rows=GROUP_B+[2]
            for c in range(0,13): al.occ[(2,c)]=1    # do corpo
        else:
            for c in range(13,16): al.occ[(2,c)]=1   # reservado p/ o arco
        for s,x,y,t in sorted(pieces,key=lambda p:-p[0]):
            hit=None
            for v,fl in flips(t):
                if (s,v.tobytes()) in known: hit=(known[(s,v.tobytes())],fl); break
            if hit is None:
                tile=al.put16(rows,t) if s==16 else al.put8(rows,t)
                if tile is None: return None
                known[(s,t.tobytes())]=tile; hit=(tile,0)
            ents.append(((0x20 if s==16 else 0)|hit[1],x,y,hit[0]))
        dma=[]
        for r in sorted(set(rows)):
            cols=[c for (rr,c) in al.data if rr==r]
            if not cols: continue
            c0=min(cols); c1=max(cols); blob=b''
            for c in range(c0,c1+1):
                t=al.data.get((r,c)); blob+=enc4(t if t is not None else np.zeros((8,8),int))
            dma.append((0x6000+r*0x100+c0*16,blob))
        res.append((ents,dma))
    return res
def build_step(body_p,arc_p):
    al=Alloc(); known={}  # bytes -> tile
    def place(pieces,prefer):
        ents=[]
        order=sorted(pieces,key=lambda p:-p[0])
        for s,x,y,t in order:
            hit=None
            for v,fl in flips(t):
                k=(s,v.tobytes())
                if k in known: hit=(known[k],fl); break
            if hit is None:
                rowsets=[prefer]+[g for g in (GROUP_A,GROUP_B) if g is not prefer]
                tile=None
                for rs in rowsets:
                    tile=al.put16(rs,t) if s==16 else al.put8(rs,t)
                    if tile is not None: break
                if tile is None: raise Exception('sem espaco de VRAM')
                known[(s,t.tobytes())]=tile; hit=(tile,0)
            ents.append(((0x20 if s==16 else 0)|hit[1], x, y, hit[0]))
        return ents
    be=place(body_p,GROUP_A); ae=place(arc_p,GROUP_B)
    # dma: por linha usada, colunas 0..max
    dma=[]
    for r in GROUP_A+GROUP_B:
        cols=[c for (rr,c) in al.occ if rr==r]
        if not cols: continue
        n=max(cols)+1; blob=b''
        for c in range(n):
            t=al.data.get((r,c)); blob+=enc4(t if t is not None else np.zeros((8,8),int))
        dma.append((0x6000+r*0x100, blob))
    return be,ae,dma
def hitbox(arc,ox,oy):
    ys,xs=np.where(arc>0)
    x0=xs.min()-ox; x1=xs.max()-ox; y0=ys.min()-oy; y1=ys.max()-oy
    cx=(x0+x1)//2; cy=(y0+y1)//2; hw=(x1-x0)//2; hh=(y1-y0)//2
    return [max(-128,min(127,v)) for v in (cx,cy,hw,hh)]
def generate():
    import pack as P
    out={'moves':{},'steps':[]}
    hb_tables={'ground':[], 'air':[]}
    cache={}
    total=0; worst=0
    for name,m in MOVES.items():
        sl=[]
        for si,(fi,dur) in enumerate(m['steps']):
            key=(m['band'],fi)
            if key not in cache:
                P.ARC_IDX[:]=[1,6,7,8,12]
                body,arc,ox,oy=frame_layers(m['band'],fi,air=m['air'])
                bp=best_pack(body,ox,oy)[1]
                ap=best_pack_smart(arc,ox,oy)[1] if arc.any() else []
                r=build_step_split(bp,ap)
                for alt,lab in (([1,7,8],'3 tons'),([1,7],'2 tons')):
                    if r is not None: break
                    P.ARC_IDX[:]=alt
                    body,arc,ox,oy=frame_layers(m['band'],fi,air=m['air'])
                    ap=best_pack_smart(arc,ox,oy)[1]
                    r=build_step_split(bp,ap); P.ARC_IDX[:]=[1,6,7,8,12]
                    if r is not None: print('  (%s)'%lab,name,si)
                assert r is not None,(name,si)
                (be,dmab),(ae,dmaa)=r
                hbv=hitbox(arc,ox,oy) if (arc>0).sum()>20 else None
                cache[key]=dict(body=be,arc=ae,dmab=dmab,dmaa=dmaa,hbv=hbv,key=key,
                    tb=sum(len(b) for d,b in dmab)//32,ta=sum(len(b) for d,b in dmaa)//32,hbidx={})
            c=cache[key]
            hb=None
            if si in m['active'] and c['hbv'] is not None:
                tname='air' if m['air'] else 'ground'
                if tname not in c['hbidx']:
                    hb_tables[tname].append(c['hbv']); c['hbidx'][tname]=len(hb_tables[tname])-1
                hb=c['hbidx'][tname]
            size=(c['tb']+c['ta'])*32; worst=max(worst,size)
            sl.append(dict(dur=dur,hb=hb,clear=si in m.get('clear',[]),frame=c,tb=c['tb'],ta=c['ta']))
        out['moves'][name]=sl
    total=sum((c['tb']+c['ta'])*32 for c in cache.values())
    return out,hb_tables,total,worst
if __name__=='__main__':
    o,h,t,w=generate()
    for n,sl in o['moves'].items(): print(n,[(s['tb'],s['ta']) for s in sl][:10],'hb',[s['hb'] for s in sl][:12])
    print('total bytes',t,'pior quadro',w, 'hitboxes',{k:len(v) for k,v in h.items()})
