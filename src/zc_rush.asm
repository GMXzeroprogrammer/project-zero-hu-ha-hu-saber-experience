;----------------------------------------------------------------------------------
; BOSS RUSH (Project By GmasterX / Claude 2026)
; Opcao "Boss Rush" no menu do titulo (aparece quando algum arquivo ja zerou o jogo).
; Equipamento completo (o mesmo do modo "cheat" do Zero Project), X ou Zero (Select).
; Chefes em ordem aleatoria. Entre as lutas: recupera 10-30% da vida maxima, o que
; passar da vida cheia vai para os sub-tanks. Comeca com os 4 sub-tanks cheios.
; Nada do Boss Rush e gravado no arquivo.
;----------------------------------------------------------------------------------
!RushArm    = $7EF700   ; X apertado na tela de load (espera o arquivo carregar)
!Rush       = $7EF701   ; boss rush ativo
!RushIdx    = $7EF702   ; lutas vencidas
!RushTimer  = $7EF703   ; espera depois da vitoria
!RushSeen   = $7EF704   ; chefe apareceu nesta luta
!RushPtr    = $7EF705   ; 16 bits: ultimo objeto do chefe
!RushCP     = $7EF707
!RushLv     = $7EF708
!RushRng    = $7EF709
!RushHPPend = $7EF70A   ; aplicar vida guardada quando a fase carregar
!RushHP     = $7EF70B
!RushHPX    = $7EF70C   ; vida reserva do X (troca)
!RushHPZ    = $7EF70D   ; vida reserva do Zero (troca)
!RushTmp    = $7EF70E   ; 16 bits
!RushOrder  = $7EF710   ; 16 bytes
!RushBak    = $7EF720   ; 12 bytes: sub-tanks originais

RushTable:              ; fase, checkpoint (perto da porta do chefe)
	db $01,$02          ; Blast Hornet
	db $02,$02          ; Blizzard Buffalo
	db $03,$02          ; Gravity Beetle
	db $04,$02          ; Toxic Seahorse
	db $05,$02          ; Volt Catfish
	db $06,$02          ; Crush Crawfish
	db $07,$02          ; Tunnel Rhino
	db $08,$02          ; Neon Tiger
	db $0A,$03          ; fortaleza 2
	db $0B,$02          ; fortaleza 3
RushTableEnd:
!RushN = (RushTableEnd-RushTable)/2

;--- tela de Load: botao X ----------------------------------------------------------
RushKey:
	PHP
	SEP #$20
	LDA !RushRng            ; o tempo que o jogador passa no menu vira a semente
	INC A
	STA !RushRng
	LDA #$00
	STA !RushArm
	LDA $00AC
	AND #$40                ; botao X
	BEQ .cont
	JSL $CAAE0E             ; o arquivo e valido?
	SEP #$30
	LDA $0026
	BNE .bad
	REP #$10
	LDX $0020
	LDA $700129,x           ; $7EF4E0 do arquivo (bit $10 = ja zerou)
	SEP #$10
	AND #$10
	BEQ .bad
	LDA #$01
	STA !RushArm
	PLP
	JML $CAB71B             ; mesma confirmacao do Load ("Load this file?")
.bad:
	LDA #$1F                ; som de negado
	JSL $81802B
	PLP
	RTL
.cont:
	PLP
	SEP #$20
	LDA $00AD
	JML $CAB62F

;--- depois de carregar o arquivo ---------------------------------------------------
RushEntry:
	LDA !RushArm
	BEQ .normal
	LDA #$00
	STA !RushArm
	JSR RushStart
	JML $809A3C             ; RTS
.normal:
	LDA $7E1FD3
	BNE +
	JML $809A21
+	JML $809A3D

RushStart:
	PHP
	SEP #$30
	LDA #$01
	STA !Rush
	LDA #$00
	STA !RushIdx
	STA !RushTimer
	STA !RushSeen
	STA !RushHPPend
	; ordem: 0..N-1 embaralhada (Fisher-Yates)
	PHB
	LDA #$7E
	PHA
	PLB
	LDX #$00
-	TXA
	STA.w !RushOrder&$FFFF,x
	INX
	CPX.b #!RushN
	BNE -
	LDX.b #!RushN-1
.shuf:
	STX.w !RushTmp&$FFFF
	JSR RushRand
-	CMP.w !RushTmp&$FFFF    ; A = rand % (i+1)
	BCC +
	BEQ +
	SEC
	SBC.w !RushTmp&$FFFF
	DEC A
	BRA -
+	TAY                     ; j
	LDA.w !RushOrder&$FFFF,x
	PHA
	LDA.w !RushOrder&$FFFF,y
	STA.w !RushOrder&$FFFF,x
	PLA
	STA.w !RushOrder&$FFFF,y
	DEX
	BNE .shuf
	PLB
	; sub-tanks: guarda os originais e enche os 4
	LDX #$03
-	LDA $7E1FB7,x
	STA !RushBak,x
	LDA $7EF400,x
	STA !RushBak+4,x
	LDA $7EF430,x
	STA !RushBak+8,x
	LDA #$8E
	STA $7E1FB7,x
	STA $7EF400,x
	STA $7EF430,x
	DEX
	BPL -
	JSR RushNext
	PLP
	RTS

RushRand:
	; A = proximo numero pseudo-aleatorio (8 bits)
	LDA !RushRng
	ASL A
	ASL A
	CLC
	ADC !RushRng            ; *5
	CLC
	ADC #$3B
	EOR $7E0B9E             ; mistura com algo que muda (contador do jogo)
	STA !RushRng
	RTS

RushNext:
	; carrega a proxima luta da lista (8 bits)
	LDA !RushIdx
	TAX
	LDA !RushOrder,x
	ASL A
	TAX
	LDA.l RushTable,x
	STA !RushLv
	STA $7E1FAE
	LDA.l RushTable+1,x
	STA !RushCP
	LDA #$00
	STA !RushSeen
	STA !RushTimer
	LDA #$02
	STA $7E00D1
	LDA #$04
	STA $7E00D2
	LDA #$00
	STA $7E00D3
	STA $7E00D4
	STA $7E00D5
	RTS

;--- inicio de fase: checkpoint do boss rush ---------------------------------------
RushCP:
	LDA #$00
	STA $7E1FB5
	LDA !Rush
	BEQ .normal
	LDA $7E1FAE
	CMP !RushLv
	BEQ +
	JSR RushEnd             ; fase diferente: boss rush abandonado
	JML $808000
+	LDA !RushCP
	STA $7E1FB5
	LDA #$00                ; Z=1: ignora o checkpoint dos creditos
	RTL
.normal:
	LDA $7E1FB3
	RTL

RushEnd:
	; desliga e devolve os sub-tanks do arquivo
	PHP
	SEP #$30
	LDA #$00
	STA !Rush
	STA !RushHPPend
	LDX #$03
-	LDA !RushBak,x
	STA $7E1FB7,x
	LDA !RushBak+4,x
	STA $7EF400,x
	LDA !RushBak+8,x
	STA $7EF430,x
	DEX
	BPL -
	PLP
	RTS

;--- tela de selecao de fases: se chegou aqui, o boss rush acabou -------------------
RushSS:
	LDA !Rush
	BEQ +
	JSR RushEnd
	JML $808000             ; boss rush acabou (game over): volta ao titulo
+	PHD
	PEA $1E58
	JML $80C207

;--- fim de fase (chefe derrotado): no boss rush vai direto para a proxima luta
RushClear:
	LDA !Rush
	BEQ +
	PHP
	SEP #$30
	LDA #$00
	STA !RushTimer
	STA !RushSeen
	JSR RushWin
	PLP
	RTL
+	LDX $1FAE
	LDA $C8973B,x
	JML $CA9A35

;--- chefes "ainda nao derrotados" durante o boss rush ------------------------------
GetE2:
	LDA !Rush
	BEQ +
	LDA #$00
	RTL
+	LDA $7EF4E2
	RTL

;--- todo quadro na fase -----------------------------------------------------------
RushTick:
	PHP
	SEP #$30
	LDA !Rush
	BNE +
	JMP .ret
+	LDA $7E1FAE
	CMP !RushLv
	BEQ +
	JSR RushEnd
	JMP .ret
+	; vida guardada da luta anterior
	LDA !RushHPPend
	BEQ .boss
	LDA $7E09DA
	BEQ .boss
	LDA $7E1F3F
	BNE .boss
	LDA #$00
	STA !RushHPPend
	LDA !RushHP
	STA $7E09FF
	LDA !RushHPX
	STA $7EF41A
	LDA !RushHPZ
	STA $7EF44A
.boss:
	LDA !RushTimer
	BNE .timer              ; ja venceu, esperando
	REP #$30
	LDA $7E1F1F
	BEQ .noboss
	STA !RushPtr
	TAX
	SEP #$20
	LDA $7E0027,x
	SEP #$10
	AND #$7F
	BEQ .hp0
	LDA #$01                ; chefe com vida (barra ja apareceu)
	STA !RushSeen
	BRA .timer
.hp0:
	LDA !RushSeen
	BEQ .timer              ; ainda enchendo a barra
	BRA .win
.noboss:
	SEP #$30
	LDA !RushSeen
	BEQ .timer
	REP #$30
	LDA !RushPtr
	TAX
	SEP #$20
	LDA $7E0027,x
	SEP #$10
	AND #$7F
	BEQ .win
	LDA #$00                ; sumiu sem morrer (o jogador morreu)
	STA !RushSeen
	BRA .timer
.win:
	LDA #$00
	STA !RushSeen
	LDA #150                ; venceu: espera a explosao
	STA !RushTimer
	BRA .ret
.timer:
	LDA !RushTimer
	BEQ .ret
	DEC A
	STA !RushTimer
	BNE .ret
	JSR RushWin
.ret:
	PLP
	RTL

RushWin:
	LDA !RushIdx
	INC A
	STA !RushIdx
	CMP.b #!RushN
	BCC +
	JSR RushEnd             ; todos derrotados: reinicia o jogo (tela de titulo)
	JML $808000
+	JSR RushHeal
	JMP RushNext

RushHeal:
	; vida maxima do personagem atual
	LDA $7E0A8E
	BEQ +
	LDA #$30
+	TAX
	LDA $7EF41B,x
	STA !RushTmp            ; maximo
	; porcentagem 10..30
	JSR RushRand
-	CMP #21
	BCC +
	SEC
	SBC #21
	BRA -
+	CLC
	ADC #10
	STA $004202
	LDA !RushTmp
	STA $004203
	NOP #4
	REP #$20
	LDA $004216
	CLC
	ADC #$0032              ; arredonda
	STA $004204
	SEP #$20
	LDA #100
	STA $004206
	NOP #8
	LDA $004214
	BNE +
	INC A                   ; pelo menos 1
+	STA !RushTmp+1          ; cura
	LDA $7E09FF
	AND #$7F
	CLC
	ADC !RushTmp+1
	CMP !RushTmp
	BCC .fits
	BEQ .fits
	SEC
	SBC !RushTmp
	STA !RushTmp+1          ; sobra -> sub-tanks
	LDA !RushTmp
	STA !RushHP
	JSR RushTanks
	BRA .done
.fits:
	STA !RushHP
.done:
	LDA $7EF41A
	STA !RushHPX
	LDA $7EF44A
	STA !RushHPZ
	LDA #$01
	STA !RushHPPend
	RTS

RushTanks:
	; enche os sub-tanks com a sobra (!RushTmp+1)
	LDA $7EF4E0
	AND #$01
	BEQ .shared
	LDA $7E0A8E
	BEQ +
	LDA #$30
+	TAX
	LDY #$04
-	JSR .one7EF4
	INX
	DEY
	BNE -
	RTS
.shared:
	LDX #$00
-	LDA $7E1FB7,x
	JSR .calc
	STA $7E1FB7,x
	INX
	CPX #$04
	BNE -
	RTS
.one7EF4:
	LDA $7EF400,x
	JSR .calc
	STA $7EF400,x
	RTS
.calc:
	; A = byte do tank -> A novo
	BIT #$80
	BEQ .r                  ; nao tem esse tank
	AND #$7F
	CLC
	ADC !RushTmp+1
	CMP #$0E
	BCC +
	SEC
	SBC #$0E
	STA !RushTmp+1
	LDA #$8E
	RTS
+	ORA #$80
	PHA
	LDA #$00
	STA !RushTmp+1
	PLA
.r:	RTS

;----------------------------------------------------------------------------------
; Menu do titulo: New Game / Load Game / Options / Boss Rush
;----------------------------------------------------------------------------------
!RushUnlock = $7EF750

MenuInit:
	PHP
	SEP #$30
	LDA #$00
	STA !RushArm            ; RAM pode ter lixo ao ligar
	STA !Rush
	JSR MenuCheckUnlock
	LDA #$00
	STA $7E003C
	JSR MenuDraw
	PLP
	RTL

MenuCheckUnlock:
	; algum dos 20 arquivos ja zerou? (arquivo valido + bit $10 de $7EF4E0)
	PHB
	LDA #$80
	PHA
	PLB
	REP #$30
	LDA #$0000
	STA !RushTmp
	LDX #$0000
.file:
	LDY #$0000
	PHX
-	LDA $700000,x
	CMP $FFC0,y
	BNE .next
	INX
	INX
	INY
	INY
	CPY #$0016
	BNE -
	PLX
	PHX
	LDA $700129,x
	AND #$0010
	BEQ .next
	PLX
	SEP #$30
	LDA #$01
	STA !RushUnlock
	PLB
	RTS
.next:
	PLX
	TXA
	CLC
	ADC #$0160
	TAX
	CPX #$1B80
	BNE .file
	SEP #$30
	LDA #$00
	STA !RushUnlock
	PLB
	RTS

MenuUp:
	LDA $3C
	DEC A
	BPL +
	LDA !RushUnlock
	CLC
	ADC #$02
+	RTL

MenuDown:
	LDA $3C
	INC A
	PHA
	LDA !RushUnlock
	CLC
	ADC #$03
	STA !RushTmp
	PLA
	CMP !RushTmp
	BNE +
	LDA #$00
+	RTL

MenuCoords:
	; posicao (Y) do X/Zero ao lado da opcao (substitui a rotina do Zero Project)
	PHP
	SEP #$30
	LDA $7E003C
	TAX
	LDA $7E1FFF
	CMP #$02
	BEQ .zero
	CPX #$03
	BEQ +
	LDA $8687F8,x
	BRA .set
+	LDA #$C6
	BRA .set
.zero:
	CPX #$03
	BEQ +
	LDA $8697AF,x
	BRA .set
+	LDA #$C1
.set:
	STA $7E09E0
	PLP
	RTL

MenuHL:
	PHP
	SEP #$30
	JSR MenuDraw
	PLP
	RTL

MenuDraw:
	; escreve as linhas do menu no buffer de VRAM do jogo ($0600, indice $A5)
	PHB
	PHK
	PLB                     ; tabelas deste banco
	LDX $A5
	LDY #$00
.line:
	CPY #$03
	BCC +
	LDA !RushUnlock
	BEQ .end
	CPY #$04
	BCS .end
+	LDA #$80
	STA $7E0600,x
	PHY
	TYA
	ASL A
	TAY
	LDA MenuAddr,y
	STA $7E0601,x
	LDA MenuAddr+1,y
	STA $7E0602,x
	PLY
	LDA MenuLen,y
	STA !RushTmp            ; quantidade de letras
	ASL A
	STA $7E0603,x
	LDA #$20                ; atributo: $24 destacado, $20 normal
	CPY $3C
	BNE +
	LDA #$24
+	STA !RushTmp+1
	PHY
	LDA MenuText,y
	TAY
	INX #4
-	LDA MenuChars,y
	STA $7E0600,x
	INX
	LDA !RushTmp+1
	STA $7E0600,x
	INX
	INY
	LDA !RushTmp
	DEC A
	STA !RushTmp
	BNE -
	PLY
	INY
	BRA .line
.end:
	STX $A5
	PLB
	RTS

MenuAddr:
	dw $0A4A,$0A8A,$0ACA,$0B0A
MenuLen:
	db 11,9,11,9
MenuText:
	db 0,11,20,31
MenuChars:
	db "New Game   "
	db "Load Game"
	db "Options    "
	db "Boss Rush"

MenuGo:
	; opcao escolhida no titulo
	LDA #$00
	STA !RushArm
	LDA $3C
	CMP #$03
	BEQ .rush
	CMP #$01
	BEQ +
	CMP #$02
	BEQ ++
	JML $808FF2             ; New Game
+	JML $808FFE             ; Load Game
++	JML $809031             ; Options
.rush:
	LDA #$01
	STA !RushArm
	STA $3D                 ; equipamento completo (modo "cheat" do Zero Project)
	LDA $7E09CB
	EOR $7E0B9E
	STA !RushRng
	JML $808FF2             ; comeca como um New Game
