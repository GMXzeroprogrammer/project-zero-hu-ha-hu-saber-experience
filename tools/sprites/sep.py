from PIL import Image
import numpy as np, json
a=np.array(Image.open('/mnt/user-data/uploads/bcf2eff9-image.png').convert('RGB')).astype(int)
bg=a[0,0]; fr=json.load(open('frames.json'))
def cls(c):
    r,g,b=c
    if (r,g,b)==tuple(bg): return 0
    if g>r+30 and g>b+20: return 2
    if min(r,g,b)>=200 and b>=r-8: return 2
    return 1
rows=[]
for bi in ['10','11','12','15']:
    ims=[]
    for (x0,y0,x1,y1) in fr[bi]:
        blk=a[y0:y1+1,x0:x1+1]
        h,w,_=blk.shape
        out=np.zeros((h,w*2+2,3),np.uint8)+40
        for y in range(h):
            for x in range(w):
                k=cls(tuple(blk[y,x]))
                if k==1: out[y,x]=blk[y,x]
                if k==2: out[y,w+2+x]=blk[y,x]
        ims.append(Image.fromarray(out))
    W=sum(i.width+6 for i in ims); Hh=max(i.height for i in ims)
    R=Image.new('RGB',(W,Hh),(0,0,0)); x=0
    for i in ims: R.paste(i,(x,0)); x+=i.width+6
    rows.append(R)
W=max(r.width for r in rows); T=Image.new('RGB',(W,sum(r.height+4 for r in rows)))
y=0
for r in rows: T.paste(r,(0,y)); y+=r.height+4
T.resize((T.width*2,T.height*2),Image.NEAREST).save('sep.png'); print(T.size)
