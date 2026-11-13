# definicao dos golpes
# steps: (quadro da folha, duracao em quadros do jogo)
# active: indices dos passos com hitbox; cancel: a partir de qual passo aceita o proximo golpe do combo
# clear: passos em que a lista de "inimigos ja atingidos" e zerada (giro acerta varias vezes)
SPIN=[(f,2) for f in range(2,10)]
MOVES={
 'slash1':dict(band='10',air=False,steps=[(0,2),(1,2),(2,2),(3,2),(4,3),(5,3),(6,4),(7,6)],active=[2,3,4],cancel=4),
 'slash2':dict(band='11',air=False,steps=[(0,2),(1,3),(2,3),(3,3),(4,4),(5,6)],active=[1,2],cancel=3),
 'slash3':dict(band='12',air=False,steps=[(0,3),(1,3),(2,3),(3,3),(4,3),(5,4),(6,4),(7,5),(8,6)],active=[1,2,3],cancel=99),
 'jump':  dict(band='15',air=True, steps=[(0,2),(1,3),(2,3),(3,3),(4,5)],active=[1,2,3],cancel=99),
 'spin':  dict(band='9', air=True, steps=[(0,2),(1,2)]+SPIN*3,active=list(range(2,26)),cancel=99,clear=[2,10,18]),
}
# porcentagem do dano original do sabre em cada golpe (sobre 256): 30%,30%,40%,70%,25%
DAMAGE=[77,77,102,179,64]
