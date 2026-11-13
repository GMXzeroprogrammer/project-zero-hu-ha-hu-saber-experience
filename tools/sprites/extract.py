from PIL import Image
import numpy as np, json
a=np.array(Image.open('/mnt/user-data/uploads/bcf2eff9-image.png').convert('RGB')).astype(int)
H,W,_=a.shape; bg=a[0,0]
mask=np.any(a!=bg,axis=2)
bands={9:(725,791),10:(831,876),11:(902,952),12:(971,1055),13:(1076,1143),14:(1156,1223),15:(1245,1314),16:(1336,1377)}
def is_arc(c):
    r,g,b=c
    if g>r+30 and g>b+20: return True          # verdes
    if min(r,g,b)>=200 and b>=r-8: return True  # brancos neutros/azulados
    return False
frames={}
for bi,(s,e) in bands.items():
    sub=mask[s-2:e+3]
    cols=sub.any(0)
    xs=np.where(cols)[0]
    segs=[];st=xs[0];p=xs[0]
    for x in xs[1:]:
        if x>p+1: segs.append((st,p)); st=x
        p=x
    segs.append((st,p))
    out=[]
    for x0,x1 in segs:
        if x1-x0<6: continue
        blk=a[s-2:e+3,x0:x1+1]; m=mask[s-2:e+3,x0:x1+1]
        ys=np.where(m.any(1))[0]
        y0=ys[0]+s-2; y1=ys[-1]+s-2
        out.append((int(x0),int(y0),int(x1),int(y1)))
    frames[bi]=out
    print(bi,len(out),out)
json.dump(frames,open('frames.json','w'))
