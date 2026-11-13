from PIL import Image
import numpy as np, json
from scipy import ndimage
from pathlib import Path
import os
HERE = Path(__file__).resolve().parent
# Supply a sprite sheet you have permission to use; it is not redistributed here.
SHEET = Path(os.environ.get("MMX3_SPRITESHEET", str(HERE / "spritesheet.png")))
if not SHEET.is_file():
    raise FileNotFoundError(f"Sprite sheet not found: {SHEET}. Set MMX3_SPRITESHEET or put spritesheet.png next to sep2.py")
A=np.array(Image.open(SHEET).convert('RGB')).astype(int)
BG=A[0,0]; FR=json.loads((HERE / 'frames.json').read_text(encoding='utf-8'))
def base_cls(c):
    r,g,b=c
    if g>r+30 and g>b+20: return 2
    if min(r,g,b)>=200 and b>=r-8: return 2
    if min(r,g,b)>=180: return 3   # claro ambiguo (creme)
    return 1
def separate(blk):
    h,w,_=blk.shape
    k=np.zeros((h,w),int)
    for y in range(h):
        for x in range(w):
            if tuple(blk[y,x])!=tuple(BG): k[y,x]=base_cls(tuple(blk[y,x]))
    st=np.ones((3,3))
    # ambiguos: componentes conectadas de (3); decide pelo vizinho dominante
    lab,n=ndimage.label(k==3,structure=st)
    for i in range(1,n+1):
        m=lab==i; d=ndimage.binary_dilation(m,structure=st)&~m
        a2=(k[d]==2).sum(); a1=(k[d]==1).sum()
        k[m]=2 if a2>a1 or (a1==0 and a2==0 and m.sum()>3) else 1
    # componentes de arco pequenas encostadas no corpo -> corpo; isoladas minusculas -> remove
    lab,n=ndimage.label(k==2,structure=st)
    for i in range(1,n+1):
        m=lab==i; sz=m.sum(); d=ndimage.binary_dilation(m,structure=st)&~m
        touch_body=(k[d]==1).sum()
        if sz<=8 and touch_body>0: k[m]=1
        elif sz<=4: k[m]=0
    return k
if __name__=='__main__':
    res={}
    for bi in ['10','11','12','15']:
        for j,(x0,y0,x1,y1) in enumerate(FR[bi]):
            blk=A[y0:y1+1,x0:x1+1]; k=separate(blk)
            np.save(f'k_{bi}_{j}.npy',k)
    print('ok')
