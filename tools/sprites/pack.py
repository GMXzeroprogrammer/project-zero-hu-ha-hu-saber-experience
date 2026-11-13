import numpy as np, json
from PIL import Image
from sep2 import A,BG,FR,separate
PAL1=['406040','20a020','60a0e0','0040a0','e0e0c0','a0a0a0','606060','e02000','a02000','602000','a06040','e0a080','40e040','e0c000','a06000','202020']
PAL3=['404080','e0e0e0','60e0e0','40c0e0','20a0e0','0080e0','60e060','40c040','40a040','e0e080','e0e000','e0a000','a0e0a0','60e060','40c040','40a040']
def hx(s): return np.array([int(s[i:i+2],16) for i in (0,2,4)])
P1=[hx(c) for c in PAL1]; P3=[hx(c) for c in PAL3]
ARC_IDX=[1,6,7,8,12]          # entradas da paleta 3 usadas pelo arco
BODY_IDX=list(range(1,16))
def nearest(c,P,idx):
    best=None
    for i in idx:
        d=((P[i]-c)**2*np.array([3,4,2])).sum()
        if best is None or d<best[0]: best=(d,i)
    return best[1]
REDS=[(220,24,0),(150,24,0),(84,24,0)]
def frame_layers(bi,j,air=False):
    x0,y0,x1,y1=FR[bi][j]; blk=A[y0:y1+1,x0:x1+1][:,::-1].copy(); k=separate(blk)
    h,w=k.shape
    body=np.zeros((h,w),int); arc=np.zeros((h,w),int)
    cache={}
    for y in range(h):
        for x in range(w):
            c=tuple(blk[y,x])
            if k[y,x]==1:
                key=('b',c)
                if key not in cache: cache[key]=nearest(np.array(c),P1,BODY_IDX)
                body[y,x]=cache[key]
            elif k[y,x]==2:
                key=('a',c)
                if key not in cache: cache[key]=nearest(np.array(c),P3,ARC_IDX)
                arc[y,x]=cache[key]
    rm=np.zeros((h,w),bool)
    for r in REDS: rm|=np.all(blk==r,axis=2)
    ys,xs=np.where(rm); cx=xs.mean(); cy=ys.mean()
    bys=np.where(body.any(1))[0]; bottom=bys.max()
    ox=int(round(cx-1)); oy=int(round(cy-2)) if air else int(bottom-23)
    return body,arc,ox,oy
def tiles_of(img,ox,oy,phase=(0,0)):
    """retorna lista de pecas (size,x,y,tile8x8 arrays) relativas a origem"""
    h,w=img.shape
    # grade relativa a origem com fase
    px,py=phase
    gx0=((-ox+px)//16)*16+ox-px if False else None
    # coordenadas relativas
    xs=np.arange(w)-ox; ys=np.arange(h)-oy
    minx=(xs[0]-px)//16*16+px; miny=(ys[0]-py)//16*16+py
    pieces=[]
    for by in range(miny,ys[-1]+1,16):
        for bx in range(minx,xs[-1]+1,16):
            def get(x,y,s):
                out=np.zeros((s,s),int)
                for yy in range(s):
                    for xx in range(s):
                        X=x+xx+ox; Y=y+yy+oy
                        if 0<=X<w and 0<=Y<h: out[yy,xx]=img[Y,X]
                return out
            b=get(bx,by,16)
            q=[b[:8,:8].any(),b[:8,8:].any(),b[8:,:8].any(),b[8:,8:].any()]
            if sum(q)>=3: pieces.append((16,bx,by,b))
            else:
                for qi,(dx,dy) in enumerate([(0,0),(8,0),(0,8),(8,8)]):
                    if q[qi]: pieces.append((8,bx+dx,by+dy,b[dy:dy+8,dx:dx+8]))
    return pieces
def count_tiles(pieces):
    seen=set(); n=0
    for s,x,y,t in pieces:
        if s==16:
            key=t.tobytes()
            vs=[t,t[:,::-1],t[::-1,:],t[::-1,::-1]]
            if any(v.tobytes() in seen for v in vs): continue
            seen.add(key); n+=4
        else:
            vs=[t,t[:,::-1],t[::-1,:],t[::-1,::-1]]
            if any(v.tobytes() in seen for v in vs): continue
            seen.add(t.tobytes()); n+=1
    return n
def best_pack(img,ox,oy):
    best=None
    for px in range(0,16,4):
        for py in range(0,16,4):
            p=tiles_of(img,ox,oy,(px,py)); n=count_tiles(p)
            if best is None or (n,len(p))<best[0]: best=((n,len(p)),p,(px,py))
    return best
if __name__=='__main__':
    for bi in ['10','11','12','15']:
        for j in range(len(FR[bi])):
            body,arc,ox,oy=frame_layers(bi,j,air=(bi=='15'))
            nb=best_pack(body,ox,oy); na=best_pack(arc,ox,oy) if arc.any() else ((0,0),[],None)
            print(bi,j,'corpo tiles %d pecas %d | arco tiles %d pecas %d'%(nb[0][0],nb[0][1],na[0][0],na[0][1]))

def solid(t): return t.min()==t.max() and t.min()>0
def tiles_of_smart(img,ox,oy,phase=(0,0)):
    """como tiles_of, mas quebra blocos 16x16 que contem tiles lisos (reaproveitaveis)"""
    out=[]
    for s,x,y,t in tiles_of(img,ox,oy,phase):
        if s==16:
            qs=[t[:8,:8],t[:8,8:],t[8:,:8],t[8:,8:]]
            nsolid=sum(1 for q in qs if solid(q))
            if nsolid>=2:
                for q,(dx,dy) in zip(qs,[(0,0),(8,0),(0,8),(8,8)]):
                    if q.any(): out.append((8,x+dx,y+dy,q))
                continue
        out.append((s,x,y,t))
    return out
def best_pack_smart(img,ox,oy,maxpieces=56):
    best=None
    for px in range(0,16,4):
        for py in range(0,16,4):
            for fn in (tiles_of,tiles_of_smart):
                p=fn(img,ox,oy,(px,py)); n=count_tiles(p)
                if len(p)>maxpieces: continue
                if best is None or (n,len(p))<best[0]: best=((n,len(p)),p,(px,py))
    return best
