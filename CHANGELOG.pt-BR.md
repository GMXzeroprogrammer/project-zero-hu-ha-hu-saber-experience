# Histórico de versões

## v1.7b
- O combo de 3 golpes no chao agora e feito PARADO, como no X4-X6
  (o 2o e o 3o golpe nao avancam mais para frente).

## v1.7
- BOSS RUSH agora e uma opcao separada no menu principal:
      New Game / Load Game / Options / Boss Rush
  * A opcao "Boss Rush" so aparece depois que algum arquivo salvo ja
    zerou o jogo.
  * Nao usa nenhum save: comeca com tudo (todas as armas, coracoes,
    armadura completa do X / Black Zero, chips e os 4 sub-tanks cheios).
  * Escolha o personagem como no New Game: SELECT no titulo = Zero.
  * Game over, sair da fase ou terminar o Boss Rush volta para a tela
    de titulo. Nada e gravado.
  * O resto continua igual: ordem aleatoria, recupera 10-30% da vida
    a cada vitoria (a sobra vai para os sub-tanks), barra roxa +100%.
- Removido o atalho antigo (botao X na tela Load Game).

## v1.6
- Dano do sabre nos inimigos comuns na proporcao do Mega Man X4
  (no X4: 1o e 2o corte = tiro normal, 3o corte = 2 tiros normais):
    * 1o corte = 1 tiro normal da buster
    * 2o corte = 1 tiro normal
    * 3o corte = 2 tiros normais
    * golpe pulando = 2 tiros normais; giro = um pouco menos que 1 tiro
      por volta
  Ex.: inimigo que morre com 3 tiros normais aguenta o 1o e o 2o
  corte e morre no 3o.
- Chefes: 1o e 2o corte = 1, 3o corte = 2 (igual ao X4 contra chefes).
- Corrigido: o 1o corte as vezes acertava duas vezes quando voce ja
  tinha apertado o proximo golpe.

## v1.5
- Corrigido: a buster do Zero estava fortissima. O tiro nao sumia ao
  acertar e batia varias vezes no mesmo inimigo (o tiro carregado
  chegava a acertar 8 vezes). Agora cada tiro acerta uma vez, igual ao
  Zero Project original.
- Corrigido: o sabre ainda matava inimigos comuns num golpe so. Agora
  cada inimigo leva no maximo 1 acerto por golpe, e contra inimigos
  comuns o dano e menor: 1o 10%, 2o 10%, 3o 14% do dano antigo
  (o combo inteiro ~ um tiro carregado). Chefes continuam como na v1.3.
- Barra roxa dos chefes:
    * jogo normal (desde o inicio): +50%
    * depois de zerar: +100%

## v1.4
- Vida extra dos chefes agora aparece na tela: uma SEGUNDA BARRA ROXA
  por cima da barra normal.
    * (na v1.5: +50% desde o inicio, +100% depois de zerar)
  A barra roxa enche depois da normal e esvazia primeiro; quando acaba,
  sobra a barra amarela original. (Agora e vida de verdade, nao mais
  reducao de dano.)
- NOVO: BOSS RUSH
    * Na tela "Load Game", coloque o cursor num arquivo que ja zerou o
      jogo e aperte X. Confirme em "Yes".
      (Arquivo que ainda nao zerou: o X da o som de "negado".)
    * Os chefes vem em ORDEM ALEATORIA, comecando perto da porta.
    * Comeca com os 4 sub-tanks cheios.
    * Ao vencer um chefe voce recupera de 10% a 30% da vida maxima;
      o que passar da vida cheia vai para os sub-tanks que nao estao
      cheios.
    * Se morrer, tenta de novo a mesma luta (vidas normais). Game over
      encerra o Boss Rush.
    * Ao derrotar todos, o jogo volta para a tela inicial.
    * Nada do Boss Rush e gravado no arquivo.
  Chefes nesta versao: os 8 Mavericks + 2 chefes da fortaleza do
  Doppler. Doppler, Sigma (em 2 lutas separadas), Vile, Bit, Byte e os
  outros chefes da fortaleza entram na proxima versao.

## v1.3
- Corrigido: particulas da carga ROSA da buster do Zero bugadas.
- Corrigido: cair no buraco com o Zero (ou com o X) nao troca mais de
  personagem - morre na hora, como no jogo original. A troca automatica
  so acontece quando a energia acaba por dano comum.
- Dano do sabre dividido entre os 3 golpes do combo: 1o 30%, 2o 30%,
  3o 40% do dano antigo (o combo inteiro ~ um golpe antigo). Golpe
  pulando 70%, giro 25% por volta. Inimigos comuns nao morrem mais com
  um unico corte.
- Contra chefes cada golpe acerta uma vez so.
- NOVO: golpe giratorio no ar = segure BAIXO + Y no ar. O Zero gira
  com o sabre (acerta a cada volta) ate tocar o chao.
- NOVO: vida dos chefes por zerada (+50% na 1a, +100% na 2a).
  (na v1.4 passou a ser mostrada pela barra roxa)

## v1.2
- Corrigido: blocos verdes espalhados pela tela no comeco dos golpes e
  no fim do 3o golpe (alguns emuladores liam o "arco vazio" como lixo).

## v1.1
- Sabre do Zero com os sprites estilo X4 (folha enviada pelo GmasterX):
    * combo de 3 golpes no chao (Y, Y, Y), cada golpe com sua animacao;
      o 2o e o 3o avancam para frente; o 3o da +2 de dano;
    * golpe pulando (Y no ar) com o arco grande.
  As areas de acerto (hitbox) foram refeitas para cada quadro novo.
- Buster do Zero (botao X) agora carrega so ate o nivel ROSA.
  O nivel verde (que terminava no golpe de sabre) foi removido.
- Corrigido: um unico toque no Y as vezes soltava dois golpes.

