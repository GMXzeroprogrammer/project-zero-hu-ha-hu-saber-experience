import numpy as np
from gen import generate
from moves import MOVES, DAMAGE
ROM=open('/home/claude/work/zp48.sfc','rb').read()
def s2p(a): return ((a&0x7f0000)>>1)|(a&0x7fff)
def rd(a,n): o=s2p(a); return ROM[o:o+n]
o,hbt,total,worst=generate()
L=[]; W=L.append
W(';; GERADO AUTOMATICAMENTE por emit.py - nao editar a mao')
# ---------- quadros unicos ----------
frames=[]; seen={}
for mv,sl in o['moves'].items():
    for s in sl:
        k=s['frame']['key']
        if k not in seen: seen[k]=len(frames); frames.append(s['frame'])
# ---------- graficos: bancos F1.. ----------
addr=0xF18000
def place_blob(b):
    global addr
    if (addr&0xffff)+len(b)>0x10000:
        addr=((addr>>16)+1)<<16|0x8000
    a=addr; addr+=len(b); return a
blobs=[]
BLANK=place_blob(bytes(32)); blobs.append((BLANK,bytes(32)))
for f in frames:
    for key in ('dmab','dmaa'):
        ents=[]
        for dst,b in f[key]:
            a=place_blob(b); ents.append((dst,len(b),a)); blobs.append((a,b))
        f[key+'e']=ents
for a,b in blobs:
    W('org $%06X'%a)
    for i in range(0,len(b),32): W('\tdb '+','.join('$%02X'%x for x in b[i:i+32]))
# ---------- dados no banco F0 ----------
W('org $F0C000')
W('ZC_DataStart:')
fid_b=0x40; fid_a=0x10
for i,f in enumerate(frames):
    W('ZC_B_%d:'%i); W('\tdb $%02X'%len(f['body']))
    for at,x,y,t in f['body']: W('\tdb $%02X,$%02X,$%02X,$%02X'%(at,x&0xff,y&0xff,t))
    f['bf']=fid_b; fid_b+=1
    if f['arc']:
        W('ZC_A_%d:'%i); W('\tdb $%02X'%len(f['arc']))
        for at,x,y,t in f['arc']: W('\tdb $%02X,$%02X,$%02X,$%02X'%(at,x&0xff,y&0xff,t))
        f['af']=fid_a; fid_a+=1
    else: f['af']=0x0F
W('ZC_A_Empty:')
W('\tdb $01,$00,$00,$00,$7B   ; 1 tile 8x8 transparente (tile $7B reservado e zerado)')
assert fid_b<=0x80 and fid_a<=0x80, (fid_b,fid_a)
W('ZC_Set4B:')
for i in range(0x40): W('\tdb $%s'%(',$'.join('%02X'%x for x in rd(0x52A700+i*3,3))))
for i,f in enumerate(frames): W('\tdl ZC_B_%d&$7FFFFF'%i)
W('ZC_Set50:')
for i in range(0x0E): W('\tdb $%s'%(',$'.join('%02X'%x for x in rd(0x0D9C0E+i*3,3))))
W('\tdl ZC_A_Empty&$7FFFFF'); W('\tdl ZC_A_Empty&$7FFFFF')
for i,f in enumerate(frames):
    if f['arc']: W('\tdl ZC_A_%d&$7FFFFF'%i)
for i,f in enumerate(frames):
    for key,suf in (('dmabe','B'),('dmaae','A')):
        ents=list(f[key])
        W('ZC_D%s_%d:'%(suf,i)); W('\tdb $%02X'%len(ents))
        for dst,n,a in ents: W('\tdw $%04X,$%04X : dl $%06X'%(dst,n,a))
# lista para zerar o tile reservado ($7B) no inicio de cada golpe
W('ZC_DBlank:')
W('\tdb $01 : dw $67B0,$0020 : dl $%06X'%BLANK)
# roteiros: dur, corpo, arco, hitbox, flags, pad, dmaB(2), dmaA(2)
# flags: bit0 = aceita proximo golpe, bit1 = envio dividido, bit2 = zera lista de inimigos atingidos
W('ZC_MoveTable:')
for mv in MOVES: W('\tdw ZC_S_%s'%mv)
W('ZC_DamageTable:')
W('\tdb '+','.join('$%02X'%d for d in DAMAGE))
for mv,m in MOVES.items():
    W('ZC_S_%s:'%mv)
    for si,s in enumerate(o['moves'][mv]):
        f=s['frame']; fi=frames.index(f)
        hbv=(s['hb']+5) if s['hb'] is not None else 0x10
        fl=(1 if si>=m['cancel'] else 0)|(2 if s['tb']+s['ta']>0x40 else 0)|(4 if s['clear'] else 0)
        W('\tdb $%02X,$%02X,$%02X,$%02X,$%02X,$00 : dw ZC_DB_%d,ZC_DA_%d'%(s['dur'],f['bf'],f['af'],hbv,fl,fi,fi))
    W('\tdb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00')
W('org $86E4B0')
for name,orig in (('Ground',0x86B837),('Air',0x86B84B)):
    W('ZC_HB_%s:'%name)
    W('\tdb '+','.join('$%02X'%x for x in rd(orig,20)))
    for hb in hbt[name.lower()]: W('\tdb '+','.join('$%02X'%(v&0xff) for v in hb))
assert 5+len(hbt['ground'])<=16 and 5+len(hbt['air'])<=16
open('/home/claude/mod/zc_data.asm','w').write('\n'.join(L)+'\n')
print('ok gfx ate %06X; quadros unicos %d (corpo %02X-%02X arco 10-%02X); pior envio %d bytes'%(addr,len(frames),0x40,fid_b-1,fid_a-1,worst))
