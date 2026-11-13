import numpy as np
from PIL import Image
from pack import frame_layers,P1,P3
from moves import MOVES
def render(body,arc,ox,oy,W=160,H=100,cx=90,cy=60):
    img=np.zeros((H,W,3),np.uint8)+np.array([40,60,90],np.uint8)
    h,w=body.shape
    for y in range(h):
        for x in range(w):
            X=x-ox+cx; Y=y-oy+cy
            if 0<=X<W and 0<=Y<H:
                if arc[y,x]: img[Y,X]=P3[arc[y,x]]
                if body[y,x]: img[Y,X]=P1[body[y,x]]
    img[cy,cx-3:cx+4]=[255,0,255]; img[cy-3:cy+4,cx]=[255,0,255]
    img[cy+23+1,:]=[90,90,90]
    return Image.fromarray(img)
rows=[]
for name,m in MOVES.items():
    ims=[]
    for fi,d in m['steps']:
        b,a,ox,oy=frame_layers(m['band'],fi,air=m['air'])
        ims.append(render(b,a,ox,oy))
    R=Image.new('RGB',(160*len(ims),100))
    for i,im in enumerate(ims): R.paste(im,(i*160,0))
    rows.append(R)
T=Image.new('RGB',(max(r.width for r in rows),100*len(rows)))
for i,r in enumerate(rows): T.paste(r,(0,i*100))
T.resize((T.width*2//2*1,T.height),Image.NEAREST).save('preview.png'); print(T.size)
