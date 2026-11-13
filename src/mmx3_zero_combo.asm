;==================================================================================
; Mega Man X3 Zero Project 4.8 - "Zero Combo + Troca" add-on
; Project By GmasterX / Claude 2026
;
; Aplicado POR CIMA da ROM ja patcheada com o Zero Project V4.8 (ROM FastROM).
;
; 1) Zero: Y = Z-Saber (combo de 3 golpes no chao, golpe aereo no ar)
;          X = Z-Buster (tiro/carga/sub-armas)
;    X (personagem): sem mudancas (tiro no Y).
; 2) Select dentro da fase troca X <-> Zero (mesma animacao de teletransporte do menu).
; 3) Se o personagem perder toda a energia por DANO, troca automaticamente para o
;    parceiro (se ele ainda tiver energia). Mortes instantaneas (buraco, espinho,
;    esmagamento) continuam matando normalmente.
;==================================================================================
lorom

!Combo      = $7EF450   ; numero do golpe atual do combo (1..3)
!Buffer     = $7EF451   ; botao do sabre apertado durante o golpe (buffer)
!Flags      = $7EF452   ; Select do quadro anterior
!Temp       = $7EF453   ; temporario
!Mode       = $7EF454   ; 0 = desligado, 1 = golpe no chao, 2 = golpe no ar (sprites novos)
!Move       = $7EF455
!Step       = $7EF456   ; passos ja tocados no golpe atual
!Timer      = $7EF457
!ScriptPtr  = $7EF458   ; 16 bits (banco $F0)
!ArcFrame   = $7EF45A
!ArcHB      = $7EF45B
!ArcAlive   = $7EF45C
!Cancel     = $7EF45D
!Fresh      = $7EF45E
!Pending    = $7EF45F   ; corpo aguardando envio (quadro pesado dividido em 2)
!PendBody   = $7EF460
!PendPtr    = $7EF461   ; 16 bits
!Instant    = $7EF463   ; dano veio do caminho de morte instantanea (buraco/espinho)
!BossAcc    = $7EF464   ; sobra da divisao do dano nos chefes
!BossHit    = $7EF465   ; (antigo)
!HitCount   = $7EF740   ; inimigos atingidos no golpe atual (0..8)
!Temp16     = $7EF742
!HitList    = $7EF744   ; 8 ponteiros (16 bits)
!BossExtra  = $7EF4C0   ; unidades da barra roxa (vida extra do chefe)
!FillLeft   = $7EF4C1   ; unidades roxas que ainda vao encher
!BossArm    = $7EF4C2   ; esperando a barra normal encher para comecar a roxa
!BossTarget = $7EF4C3   ; tamanho da barra roxa nesta luta (16 ou 32)
!PurpleOn   = $7EF4C4   ; tile/cor roxa carregados

!MaxCombo   = $03       ; quantidade de golpes do combo
!CutFrame   = $07       ; quadro da animacao a partir do qual o proximo golpe pode sair
!NextStart  = $02       ; quadro inicial dos golpes 2 e 3

!LungeFrames = $00      ; quantos passos do golpe o Zero avanca (0 = parado, como no X4-X6)
!Lunge2     = $0200     ; velocidade do avanco no 2o golpe (1.5 px/quadro)
!Lunge3     = $0300     ; velocidade do avanco no 3o golpe (3 px/quadro)

!PurpleColor = $7916    ; roxo da barra extra (SNES BGR555)

!PCMenuSwap = $CA81E3   ; rotina do Zero Project: pode trocar de personagem nesta fase? (A=0 sim)

;----------------------------------------------------------------------------------
; Ganchos no codigo original
;----------------------------------------------------------------------------------

; (1) Leitura de controle: depois de montar $0A0E/$0A0F, remapeia para o Zero
org $80E4CA
	JSL InputRemap
	RTS

; (2) Gatilho do Z-Saber (antes exigia a "carga" $0A8F, que nunca era liberada para o Zero)
org $84AED6
	JSL SaberTrigger
	BCS +
	RTS
	NOP #11
+
assert pc() == $84AEE8

; (3) Corte no chao (estado 5C): inicio do golpe e combo
org $849507
	JSL GroundStart         ; (STZ $90 / STZ $1F44 originais vao junto)
	NOP
assert pc() == $84950C
org $84950C
	JSL ComboCheck
	NOP #3
assert pc() == $849513

; (3a) Corte no ar (estado 5E)
org $849B68
	JSL AirStart
	NOP #3
assert pc() == $849B6F
org $849B70
	JSL AirTick             ; termina com LDA $5E / BIT #$04 (original)
assert pc() == $849B74

; (3d) Sprites novos: o jogo nao envia tiles quando o golpe novo esta ativo
org $CA9751
	JML PlayerVramHook
org $818D04
	JSL ArcVram
org $818D84
	JSL ArcAnim
	JSL ArcVram
assert pc() == $818D8C
; tabelas de hitbox do Zero (copias com os golpes novos no fim)
org $818DE4
	LDA.w #ZC_HB_Ground
org $818DE9
	LDA.w #ZC_HB_Air

; (3b) Dano do sabre: bonus no 3o golpe
org $84CF0B
	JSL SaberDamage

; (3c) Buster do Zero para no nivel rosa (o verde arma o sabre finalizador)
org $84ACFC
	JSL ChargeTick
assert pc() == $84AD00

; (3e) Fim dos creditos: conta a 2a zerada
org $CABC2A
	JSL ClearCount
	NOP
assert pc() == $CABC2F

; (3f) Barra de vida do chefe: barra roxa por cima da normal (vida extra nas zeradas)
org $8392BF
	JML BarCheck
org $8392E2
	JSL BarInit
	NOP
assert pc() == $8392E7
org $839322
	JML BarTick
org $8393C1
	JSL BarEnd
	NOP
assert pc() == $8393C6
org $8393D9
	JSL BarEnd
	NOP
assert pc() == $8393DE

; (4) Select troca de personagem (no mesmo ponto onde o jogo abre o menu com Start)
org $80A323
	JSL SelectSwap
	db $F0,$46              ; BEQ $80A36F (pula a abertura do menu)
	NOP
assert pc() == $80A32A

; (5) Energia zerada por dano -> troca automatica (dois caminhos de dano do jogo)
org $84CE17
	JSL DeathHook
	NOP #4
assert pc() == $84CE1F

org $84D09F
	JSL DeathHook
	NOP #4
assert pc() == $84D0A7

; (5b) marca qual entrada de dano foi usada
org $84D066
	JML DmgInstant          ; entrada $84D065: morte instantanea (buraco etc.)
org $84D06B
	SEP #$30
	db $80,$01              ; BRA $84D070
org $84D070
	JML DmgNormal           ; entradas $84D06A/$84D06F: dano com animacao
assert pc() == $84D074

; (6) Boss Rush
org $808EFD
	JSL MenuInit            ; menu do titulo: desenha as opcoes (+ Boss Rush)
	NOP
assert pc() == $808F02
org $808F3C
	JSL MenuUp
	db $80,$10              ; BRA $8F52
org $808F49
	JSL MenuDown
	db $80,$03              ; BRA $8F52
org $808F5B
	JSL MenuHL              ; destaque da opcao escolhida
	NOP #4
assert pc() == $808F63
org $808FE5
	JML MenuGo
org $CAA8D0
	JML MenuCoords
org $809A1C
	JML RushEntry           ; depois de carregar o arquivo
org $809A75
	JSL RushCP
	NOP #2
assert pc() == $809A7B
org $80C203
	JML RushSS
org $CA9A2E
	JML RushClear           ; fim de fase              ; tela de selecao de fases
org $CAA7C2
	JSL GetE2
org $CAA7C9
	JSL GetE2
org $CAA7D0
	JSL GetE2
org $CAA7D7
	JSL GetE2
org $CAA7DE
	JSL GetE2
org $CAA7E5
	JSL GetE2
org $CAA7EC
	JSL GetE2
org $CAA7F3
	JSL GetE2
org $CAA807
	JSL GetE2

;----------------------------------------------------------------------------------
; Codigo novo (banco livre $F0)
;----------------------------------------------------------------------------------
org $F08000
db "ZERO COMBO+TROCA GmasterX/Claude 2026",$00

InputRemap:
	; Entrada: A/X 8-bit. $0A0E/$0A0F = botoes segurados (ja convertidos pela config)
	LDA $7E0A8E
	CMP #$02
	BNE .compute            ; so o Zero
	LDA $7E09DA
	CMP #$2C
	BEQ .compute            ; dentro da Ride Armor: controles normais

	LDA $7E0A0E
	AND #$BF
	STA $7E0A0E
	LDA $7E0A0F
	BIT #$40                ; botao de tiro da config (padrao Y)
	BEQ .noSaber
	LDA $7E0A0E
	ORA #$40                ; vira o botao do sabre ($0A0E bit 6, livre)
	STA $7E0A0E
.noSaber:
	LDA $7E0A0F
	AND #$BF
	STA $7E0A0F
	LDA $7E00A8
	AND #$40                ; botao X fisico
	BEQ .compute
	LDA $7E0A0F
	ORA #$40                ; vira o botao de tiro
	STA $7E0A0F
.compute:
	REP #$20
	LDA $7E0A10
	EOR #$FFFF
	AND $7E0A0E
	STA $7E0A12             ; botoes recem-apertados
	SEP #$20
	RTL

SaberTrigger:
	; D = $09D8 (objeto do jogador). Retorna C=1 para cortar.
	LDA $B6
	CMP #$02
	BNE .x
	LDA $3A
	AND #$40                ; sabre recem-apertado (Zero)
	BEQ .no
	LDA $02
	CMP #$5C                ; ja esta cortando no chao -> quem decide e o combo
	BEQ .no
	CMP #$5E                ; ja esta cortando no ar
	BEQ .no
	LDA #$01
	STA !Combo
	LDA #$00
	STA !Buffer
	STA !ArcAlive
	STA !Mode
	JSR ClearSaberTable
	SEC
	RTL
.x:	; comportamento original (X com o Z-Saber)
	LDA #$40
	BIT $3B
	BEQ .no
	LDA $B7
	BEQ .no
	LDA $33
	BEQ .yes
	CMP #$12
	BNE .no
.yes:	SEC
	RTL
.no:	CLC
	RTL

SaberDamage:
	; dano de qualquer arma em inimigos. D = objeto do inimigo atingido
	JSL $CA8ECF             ; CheckZSaberDamage do Zero Project (A = dano, tambem em $0000)
	PHP
	REP #$10
	PHX                     ; X (16 bits) = objeto do tiro/golpe: o jogo usa depois
	SEP #$30
	STA !Temp
	BEQ .jdone
	BPL .go
.jdone:
	JMP .done
.go:
	; --- sabre do Zero: cada golpe tem uma parte do dano original
	LDA $7E1F2F
	CMP #$02
	BNE .jboss
	LDA $7E0A8E
	CMP #$02
	BNE .jboss
	LDA !Mode
	BNE .saber
.jboss:
	JMP .boss
.saber:
	LDA !Move
	TAX
	REP #$20
	TDC
	CMP $7E1F1F
	SEP #$20
	BEQ .tboss
	LDA.l ZC_DamageTableE,x ; inimigos comuns: parte menor
	BRA .tset
.tboss:
	LDA.l ZC_DamageTable,x  ; chefes
.tset:
	STA $004202
	LDA !Temp
	STA $004203
	NOP #4
	REP #$20
	LDA $004216
	CLC
	ADC #$0080              ; arredonda
	XBA
	SEP #$20
	BNE +
	LDA #$01                ; minimo 1
+	STA !Temp
	; cada inimigo leva so um acerto por golpe (lista dos ja atingidos)
	REP #$30
	TDC
	STA !Temp16
	LDA !HitCount
	AND #$0007
	ASL A
	TAX
-	DEX
	DEX
	BMI .newhit
	LDA !HitList,x
	CMP !Temp16
	BNE -
	SEP #$30
	LDA #$00                ; ja levou este golpe
	STA $7E0000
	JMP .done
.newhit:
	LDA !HitCount
	AND #$0007
	ASL A
	TAX
	LDA !Temp16
	STA !HitList,x
	SEP #$30
	LDA !HitCount
	CMP #$08
	BCS +
	INC A
	STA !HitCount
+
.boss:
	; --- chefes: a barra roxa (vida extra das zeradas) absorve o dano primeiro
	REP #$20
	TDC
	CMP $7E1F1F
	SEP #$20
	BNE .store
	LDA !FillLeft           ; se a barra roxa ainda estava enchendo, completa na hora
	CLC
	ADC !BossExtra
	STA !BossExtra
	LDA #$00
	STA !FillLeft
	STA !BossArm
	LDA !BossExtra
	BEQ .store
	CMP !Temp
	BCC .over
	SEC
	SBC !Temp               ; roxo aguenta todo o golpe
	STA !BossExtra
	LDA #$00
	STA !Temp
	BRA .redraw
.over:
	LDA !Temp               ; sobra passa para a barra normal
	SEC
	SBC !BossExtra
	STA !Temp
	LDA #$00
	STA !BossExtra
.redraw:
	LDA $27
	ORA #$80                ; pede para redesenhar a barra
	STA $27
.store:
	LDA !Temp
	STA $7E0000
.done:
	REP #$10
	PLX
	PLP
	LDA $7E0000
	RTL

ZC_DamageTableE:
	db 26,26,51,51,20       ; /256: combo 10%,10%,20% | pulo 20% | giro 8% (inimigos comuns, proporcao do X4)

ClearCount:
	; fim dos creditos: se ja era NG+, marca a 2a zerada (bit $20)
	LDA $0000
	BIT #$10
	BEQ +
	ORA #$20
+	ORA #$10
	RTL

GroundStart:
	STZ $90
	LDA #$00
	STA $7E1F44
	LDA $B6
	CMP #$02
	BNE .x
	LDA !Mode
	CMP #$02
	BNE .new
	; pousou no meio do golpe aereo -> encerra
	LDA #$00
	STA !Mode
	LDA #$80
	STA $0F
	RTL
.new:
	LDA !Combo
	BEQ +
	DEC A
+	CMP #$03
	BCC +
	LDA #$02
+	JSR StartMove
	LDA #$01
	STA !Mode
.x:	RTL

AirStart:
	STZ $90
	LDA #$07
	STA $7E1F44
	LDA $B6
	CMP #$02
	BNE .x
	LDA $37
	AND #$04                ; Baixo segurado?
	BEQ +
	LDA #$04                ; giro aereo
	BRA ++
+	LDA #$03                ; golpe pulando
++	JSR StartMove
	LDA #$02
	STA !Mode
.x:	RTL

AirTick:
	LDA $B6
	CMP #$02
	BNE +
	JSL DriverTick
+	LDA $5E
	BIT #$04
	RTL

StartMove:
	; A = numero do golpe. D = $09D8
	PHP
	SEP #$30
	STA !Move
	ASL A
	TAX
	REP #$20
	LDA.l ZC_MoveTable,x
	STA !ScriptPtr
	SEP #$20
	LDA #$00
	STA !Step
	STA !Buffer
	STA !Pending
	STA !BossHit
	STA !HitCount
	LDA #$01
	STA !Fresh
	REP #$10
	LDX.w #ZC_DBlank
	JSR QueueDMA            ; zera o tile reservado $7B
	SEP #$10
	JSR LoadStep
	LDA !ArcAlive
	BNE .alive
	LDA $0F
	ORA #$40                ; o jogo cria o objeto do arco do sabre
	STA $0F
	BRA .done
.alive:
	LDA #$46                ; som do sabre (o arco ja existe)
	JSL $81802B
.done:
	PLP
	RTS

DriverTick:
	PHP
	SEP #$30
	LDA !Mode
	BEQ .out
	LDA !ArcAlive
	BEQ +
	DEC A
	STA !ArcAlive
+	LDA !Fresh
	BEQ +
	LDA #$00
	STA !Fresh
	BRA .out
+	LDA $0F
	BMI .out                ; golpe terminou
	LDA !Pending
	BEQ +
	LDA #$00
	STA !Pending
	LDA !PendBody
	STA $17
	REP #$30
	LDA !PendPtr
	TAX
	SEP #$20
	JSR QueueDMA
	SEP #$10
+	LDA $0F
	AND #$BF
	STA $0F
	LDA #$7F
	STA $13
	LDA !Timer
	DEC A
	STA !Timer
	BNE .out
	REP #$20
	LDA !ScriptPtr
	CLC
	ADC #$000A
	STA !ScriptPtr
	SEP #$20
	JSR LoadStep
.out:
	PLP
	RTL

LoadStep:
	; le o passo atual do roteiro e aplica
	REP #$30
	LDA !ScriptPtr
	TAX
	SEP #$20
	LDA.l ZC_Bank<<16,x     ; duracao
	BNE +
	LDA $0F
	ORA #$80                ; fim do golpe
	STA $0F
	LDA #$01
	STA !Timer
	SEP #$10
	RTS
+	STA !Timer
	LDA.l (ZC_Bank<<16)+2,x
	STA !ArcFrame
	LDA.l (ZC_Bank<<16)+3,x
	STA !ArcHB
	LDA.l (ZC_Bank<<16)+4,x
	AND #$04
	BEQ +
	JSR ClearSaberTable     ; nova volta do giro: pode acertar de novo
+	LDA.l (ZC_Bank<<16)+4,x
	AND #$01
	STA !Cancel
	LDA !Step
	AND #$0F
	STA $0F
	INC A
	STA !Step
	LDA #$7F
	STA $13
	; tiles do arco: sempre ja
	PHX
	REP #$20
	LDA.l (ZC_Bank<<16)+8,x
	TAX
	SEP #$20
	JSR QueueDMA
	PLX
	LDA.l (ZC_Bank<<16)+4,x
	AND #$02
	BEQ .now
	; quadro pesado: corpo no proximo quadro
	LDA.l (ZC_Bank<<16)+1,x
	STA !PendBody
	REP #$20
	LDA.l (ZC_Bank<<16)+6,x
	STA !PendPtr
	SEP #$20
	LDA #$01
	STA !Pending
	SEP #$10
	RTS
.now:
	LDA.l (ZC_Bank<<16)+1,x
	STA $17                 ; quadro do corpo (sem bit 7: o envio de tiles e nosso)
	REP #$20
	LDA.l (ZC_Bank<<16)+6,x
	TAX
	SEP #$20
	JSR QueueDMA
	SEP #$10
	RTS

QueueDMA:
	; X = lista (banco $F0): n, depois [destino(2) tamanho(2) origem(3)]
	PHB
	LDA #$7E
	PHA
	PLB
	LDA.l ZC_Bank<<16,x
	STA !Temp
	INX
	REP #$20
	LDA $00A4
	AND #$00FF
	TAY
.loop:
	SEP #$20
	LDA !Temp
	BEQ .end
	DEC A
	STA !Temp
	CPY #$00F8
	BCS .end                ; fila cheia
	LDA #$80
	STA $0500,y
	REP #$20
	LDA.l ZC_Bank<<16,x
	STA $0501,y
	LDA.l (ZC_Bank<<16)+2,x
	STA $0503,y
	LSR #5
	CLC
	ADC $1F38
	STA $1F38
	LDA.l (ZC_Bank<<16)+4,x
	STA $0505,y
	SEP #$20
	LDA.l (ZC_Bank<<16)+6,x
	STA $0507,y
	REP #$21
	TYA
	ADC #$0008
	TAY
	TXA
	CLC
	ADC #$0007
	TAX
	BRA .loop
.end:
	SEP #$20
	TYA
	STA $00A4
	PLB
	RTS

ComboCheck:
	; estado 5C, sub-estado 2. D = $09D8
	LDA $B6
	CMP #$02
	BNE .orig
	JSL DriverTick
	LDA !Mode
	BEQ .orig
	LDA !Step
	CMP #$02
	BCC +
	LDA $3A
	AND #$40
	BEQ +
	LDA #$01
	STA !Buffer             ; guarda o aperto para o proximo golpe
+	LDA !Buffer
	BEQ .lunge
	LDA !Cancel
	BEQ .lunge
	LDA !Combo
	CMP #!MaxCombo
	BCS .lunge
	INC A
	STA !Combo
	LDA #$00
	STA !Buffer
	LDA !HitCount           ; o golpe atual ainda esta ativo neste quadro
	PHA
	JSR ClearSaberTable
	PLA
	STA !HitCount
	STZ $03                 ; reinicia o estado -> GroundStart escolhe o proximo golpe
	RTL
.lunge:
	JSR Lunge
.orig:
	LDA $0F
	BPL .ret
	PLA
	PLA
	PLA
	JML $84A6EA             ; fim: volta ao normal
.ret:	RTL

Lunge:
	; avanco para frente nos golpes 2 e 3 (para em paredes)
	LDA $5E
	AND #$04
	BEQ .end                ; so no chao
	LDA !Step
	CMP #!LungeFrames
	BCS .end
	LDA !Move
	BEQ .end
	CMP #$03
	BCS .end
	CMP #$02
	REP #$20
	LDA #!Lunge2
	BCC +
	LDA #!Lunge3
+	STA $1A
	SEP #$20
	BIT $69                 ; $0A41 bit 6 = olhando para a direita
	BVS .right
	LDA $5E
	AND #$02
	BNE .stop
	REP #$20
	LDA $1A
	EOR #$FFFF
	INC A
	STA $1A
	SEP #$20
	BRA .move
.right:
	LDA $5E
	AND #$01
	BNE .stop
.move:
	JSL $82D7F3
.stop:
	STZ $1A
	STZ $1B
.end:
	RTS

PlayerVramHook:
	; substitui o inicio da rotina de envio de tiles do Zero Project ($CA9751)
	PHP
	SEP #$30
	JSR ModeActive
	BCC .orig
	REP #$20
	TDC
	CMP #$09D8
	SEP #$20
	BNE .orig
	LDA $17
	AND #$7F
	STA $17
	PLP
	RTL
.orig:
	STZ $0006
	JML $CA9757

ArcAnim:
	; objeto do arco: no modo novo, quadro e hitbox vem do motor
	PHP
	SEP #$30
	JSR ModeActive
	BCC .orig
	LDA #$02
	STA !ArcAlive
	LDA !ArcFrame
	STA $17
	LDA !ArcHB
	STA $0F
	LDA #$7F
	STA $13
	LDA $7E1F44
	STA $3C
	PLP
	RTL
.orig:
	PLP
	JML $84B94A

ArcVram:
	PHP
	SEP #$30
	JSR ModeActive
	BCC .orig
	LDA $17
	AND #$7F
	STA $17
	PLP
	RTL
.orig:
	PLP
	JML $84BCA2

ModeActive:
	; C=1 se o modo novo esta ativo e o Zero esta cortando
	LDA !Mode
	BEQ .no
	LDA $7E09DA
	CMP #$5C
	BEQ .yes
	CMP #$5E
	BEQ .yes
	LDA #$00
	STA !Mode
.no:	CLC
	RTS
.yes:	SEC
	RTS

ChargeTick:
	INC $57                 ; tempo de carga
	LDA $B6
	CMP #$02
	BNE +
	LDA $57
	CMP #$C8                ; $C8 = nivel verde
	BCC +
	LDA #$C7
	STA $57                 ; Zero fica no rosa
+	LDA $57
	RTL

ClearSaberTable:
	; libera os inimigos para levarem dano do sabre de novo (funciona com X de 8 ou 16 bits)
	PHP
	REP #$10
	PHX
	SEP #$20
	LDA #$00
	STA !BossHit
	STA !HitCount
	LDX.w #$000F
-	LDA #$00
	STA $7EF500,x
	DEX
	BPL -
	PLX
	PLP
	RTS

SelectSwap:
	LDA $7E00A9
	AND #$20                ; Select segurado (controle fisico)
	STA !Temp
	LDA !Flags              ; estado do quadro anterior
	EOR #$20
	AND !Temp               ; 1 so se agora segurado E antes solto
	PHA
	LDA !Temp
	STA !Flags
	PLA
	BEQ .menu
	PHP
	SEP #$30
	JSR CanSwap
	BCC .denied
	JSR DoSwap
	PLP
	LDA #$00                ; Z=1 -> nao abre o menu
	RTL
.denied:
	PLP
.menu:
	LDA $7E0A13
	AND #$10
	RTL

DmgInstant:
	SEP #$30
	JSR MarkBigDamage
	JML $84D084
DmgNormal:
	SEP #$30
	JSR MarkBigDamage
	LDA #$8E
	JML $84D074
MarkBigDamage:
	; dano >= $40 (buraco, espinho, esmagamento) = morte instantanea
	LDA #$00
	STA !Instant
	LDA $7E09FE
	CMP #$40
	BCC +
	LDA #$01
	STA !Instant
+	RTS

DeathHook:
	PHP
	SEP #$30
	LDA #$00
	STA $7E09FF
	LDA !Instant
	BEQ +
	LDA #$00
	STA !Instant
	BRA .die                ; buraco/espinho: morre de verdade
+	JSR CanSwap
	BCC .die
	JSR DoSwap
	PLP
	RTL
.die:
	LDA #$8C                ; morte normal
	STA $7E0A7B
	PLP
	RTL

CanSwap:
	; A/X/Y 8-bit. C=1 se pode trocar para o parceiro.
	LDA $7E09DA
	CMP #$2C                ; Ride Armor
	BEQ .no
	CMP #$76                ; ja trocando
	BEQ .no
	CMP #$0C                ; morrendo
	BEQ .no
	LDA $7E0A8E
	CMP #$03
	BCS .no                 ; so X (0) ou Zero (2)
	PHB
	LDA #$80                ; DB precisa enxergar a WRAM ($0A8E, $1FB2...)
	PHA
	PLB
	JSL !PCMenuSwap         ; regras do Zero Project (fase / Z-Saber do X)
	PLB
	SEP #$30
	CMP #$00
	BNE .no
	LDA $7E1F5D
	BMI .no
	LDA $7E0A8E
	BNE .partnerIsX
	LDA $7EF44A             ; energia guardada do Zero
	BRA .chk
.partnerIsX:
	LDA $7EF41A             ; energia guardada do X
.chk:	AND #$7F
	BEQ .no                 ; parceiro sem energia
	SEC
	RTS
.no:	CLC
	RTS

DoSwap:
	LDA $7E0A8E
	EOR #$02
	STA $7E1FFF
	LDA #$76
	STA $7E09DA
	LDA #$00
	STA $7E09DB
	STA $7E0A7B
	RTS

;----------------------------------------------------------------------------------
; Listas de quadros: conjunto $4B (corpo do Zero com sabre) e $50 (arco)
;----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------
; Barra dupla do chefe
;----------------------------------------------------------------------------------
BarInit:
	; inicio da barra do chefe (roda todo quadro ate a luta comecar). A 8 bits, X 16 bits
	LDA !PurpleOn
	BNE .none               ; ja preparado
	LDA #$00
	STA !BossExtra
	STA !FillLeft
	STA !BossArm
	LDA $7EF4E0
	AND #$10
	BEQ +
	LDA #$20                ; depois de zerar: +100%
	BRA ++
+	LDA #$10                ; desde o inicio: +50%
++	STA !BossTarget
	LDA #$01
	STA !BossArm
	STA !PurpleOn
	; cor roxa no indice 10 da paleta 2 de sprites (sem uso nas fases)
	REP #$20
	LDA.w #!PurpleColor
	STA $7E0454
	SEP #$20
	PHY
	LDX.w #ZC_PurpleDMA
	JSR QueueDMA
	PLY
.none:
	LDA #$AA
	STA.l $006203
	RTL

BarCheck:
	; sem chefe ($1F1F = 0): desfaz a barra roxa se ainda estiver carregada
	JSL RushTick
	LDX $1F1F
	BEQ +
	JML $8392C4
+	JSL BarEnd
	JML $8392BE             ; RTS

BarEnd:
	; barra do chefe sumindo: devolve tile e cor originais
	LDA !PurpleOn
	BEQ +
	LDA #$00
	STA !PurpleOn
	STA !BossExtra
	STA !FillLeft
	STA !BossArm
	REP #$20
	LDA.w #$5903
	STA $7E0454
	SEP #$20
	PHY
	LDX.w #ZC_BlueDMA
	JSR QueueDMA
	PLY
+	LDX.w #$0018
	LDA #$E0
	RTL

BarTick:
	; estado 2 da barra (todo quadro). Y/X 16 bits, A 8 bits
	LDY $1F1F
	LDA !BossArm
	BEQ .fill
	LDA $0027,y
	AND #$7F
	CMP #$20
	BNE .fill
	LDA #$00                ; barra normal cheia: comeca a encher a roxa
	STA !BossArm
	LDA !BossTarget
	STA !FillLeft
.fill:
	LDA !FillLeft
	BEQ .chk
	DEC A
	STA !FillLeft
	LDA !BossExtra
	INC A
	STA !BossExtra
	LDA $0027,y
	ORA #$80
	STA $0027,y
	LDA !FillLeft
	AND #$01
	BNE .chk
	PHP
	PHB
	LDA #$1F                ; som de encher a barra
	JSL $81802B
	PLB
	PLP
	LDY $1F1F
.chk:
	LDA $0027,y
	BMI .draw
	JML $8393C0             ; RTS
.draw:
	AND #$7F
	STA $00
	LDA !BossExtra
	BNE .double
	JML $839331             ; desenho original
.double:
	; parte de baixo: roxo (tile $C4); parte de cima: barra normal cheia (tile $80)
	STA $00
	LDA #$40
	STA $01
	LDX.w #$0004
.p1:
	LDA $00
	BEQ .p1end
	SEC
	SBC #$08
	STA $00
	BMI .p1part
	LDA $01
	STA $6041,x
	SEC
	SBC #$10
	STA $01
	LDA #$C4
	STA $6042,x
	INX #4
	BRA .p1
.p1part:
	ASL $00
	LDA $01
	SEC
	SBC $00
	STA $6041,x
	SEC
	SBC #$10
	STA $01
	LDA #$C4
	STA $6042,x
	INX #4
.p1end:
	LDA $0027,y
	AND #$7F
	STA $0027,y
	LDA #$20
	SEC
	SBC !BossExtra
	STA $00
.p2:
	LDA $00
	SEC
	SBC #$08
	STA $00
	BMI .p2part
	LDA $01
	STA $6041,x
	SEC
	SBC #$10
	STA $01
	LDA #$80
	STA $6042,x
	INX #4
	BRA .p2
.p2part:
	ASL $00
	LDA $01
	SEC
	SBC $00
	STA $6041,x
	SEC
	SBC #$10
	STA $01
	LDA #$80
	STA $6042,x
	INX #4
	LDA $01
	STA $6041,x
	LDA #$84
	STA $6042,x
	JML $8393C0

ZC_PurpleDMA:
	db $02 : dw $6C40,$0040 : dl ZC_PurpleTile : dw $6D40,$0040 : dl ZC_PurpleTile
ZC_BlueDMA:
	db $02 : dw $6C40,$0040 : dl ZC_BlueTile : dw $6D40,$0040 : dl ZC_BlueTile
incsrc zc_bar.asm
incsrc zc_rush.asm

org $8D80E1
	dl ZC_Set4B&$7FFFFF
org $8D80F0
	dl ZC_Set50&$7FFFFF

ZC_Bank = $F0
incsrc zc_data.asm

