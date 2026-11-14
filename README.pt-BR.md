# Mega Man X3: Project Zero - Hu Ha Hu! Edition (Saber Experience)

[English](README.md) | **Português (Brasil)**  
**Versão:** v1.7b • **Plataforma:** Super Nintendo (SNES) • **Mod-base:** Zero Project v4.8, de Justin3009

> Uma modificação não oficial de **Mega Man X3** focada na experiência de combate com o sabre do Zero. Inclui combo de três golpes, Z-Buster em botão separado, troca de personagens durante as fases, chefes reforçados e um modo Boss Rush desbloqueável.
>
> **Nenhuma ROM do jogo está incluída.** Este repositório contém patches IPS, código-fonte e documentação. Utilize sua própria cópia obtida legalmente e compatível com a modificação.

## Novidades

- **Z-Saber do Zero no Y:** Combo de três golpes **parado** no chão, inspirado em *Mega Man X4-X6*, além de ataque aéreo. Aperte **Baixo + Y** no ar para executar o golpe giratório.
- **Z-Buster do Zero no X:** Disparo normal e carga até o nível rosa. O antigo golpe final de sabre associado à carga verde foi removido.
- **Troca de personagem no Select:** Alterne entre X e Zero nas fases permitidas pelo Zero Project original. Cada um mantém sua própria barra de vida. Se um personagem perder toda a energia por dano comum, o parceiro pode assumir, caso esteja disponível. Quedas em buracos, espinhos e esmagamentos continuam causando morte imediata.
- **X mantém os controles conhecidos:** O botão Y continua disparando e carregando o X-Buster.
- **Vida extra dos chefes:** Uma barra roxa adicional aumenta a resistência dos chefes em 50% na campanha normal e 100% após terminar o jogo.
- **Boss Rush:** Opção no menu principal após algum arquivo salvo ter concluído o jogo. Comece com equipamento completo, enfrente chefes em ordem aleatória, recupere parte da vida entre lutas e volte sem alterar os arquivos salvos. Lista atual: oito Mavericks e dois chefes da fortaleza de Doppler; os demais ainda não foram incluídos.

## Controles

| Personagem | Comando | Ação |
|---|---|---|
| Zero | `Y` | Z-Saber; pressione novamente para continuar o combo de três golpes no chão |
| Zero | `Y` no ar | Corte aéreo |
| Zero | `Baixo + Y` no ar | Golpe giratório de sabre |
| Zero | `X` | Z-Buster, carga até o rosa; subarmas |
| X | `Y` | X-Buster (inalterado) |
| X / Zero | `Select` | Troca de personagem, onde o mod-base permitir |

## Instalação

Use o [Floating IPS (Flips)](https://www.romhacking.net/utilities/1040/) ou outro programa compatível com IPS. Escolha **apenas um** arquivo da pasta `patches/`:

| Arquivo de patch | Aplicar em |
|---|---|
| `MMX3_ZeroCombo_v1.7b_rom_original.ips` | ROM limpa **Mega Man X3 (USA)**, **sem header**. Este patch já inclui as alterações do Zero Project v4.8. |
| `MMX3_ZeroCombo_v1.7b_sobre_ZP48.ips` | ROM compatível na qual **Zero Project v4.8** já foi aplicado. |

**Atenção:** Não aplique os dois patches, nem instale a v1.7b sobre versões antigas desta modificação. Faça uma cópia de segurança antes. Não há garantia de compatibilidade com outras regiões, ROMs com header ou hacks adicionais.

## Compilação do código-fonte

O código de montagem foi incluído para estudo e continuidade do desenvolvimento. Requisitos:

- [Asar](https://github.com/RPGHacker/asar) (1.8x)
- ROM compatível já modificada com Zero Project v4.8

```bash
cp "Mega Man X3 ZP48.sfc" "build.sfc"
asar --fix-checksum=on src/mmx3_zero_combo.asm build.sfc
```

O arquivo principal é `src/mmx3_zero_combo.asm`, complementado por `src/zc_data.asm`, `src/zc_bar.asm` e `src/zc_rush.asm`.

A pasta `tools/sprites/` contém os scripts Python para converter sprites. A folha original de sprites **não é redistribuída**. Para usar os conversores, forneça uma folha de sprites apropriada em `tools/sprites/spritesheet.png` ou configure a variável de ambiente `MMX3_SPRITESHEET`. Instale as dependências do arquivo `requirements.txt`. Os dados `src/zc_data.asm` já estão gerados, então a compilação do código existente não exige a folha original. Alguns scripts auxiliares podem depender de outros arquivos do projeto.

## Histórico de versões

Veja o [CHANGELOG.md](CHANGELOG.md) em inglês ou o [CHANGELOG.pt-BR.md](CHANGELOG.pt-BR.md) em português brasileiro.

## Créditos e agradecimentos

- **Mega Man X3:** © Capcom. Os direitos da obra original pertencem aos respectivos titulares.
- **Zero Project v4.8:** **Justin3009** (também conhecido como xJustin3009x / Shishisenkou). Esta modificação parte do trabalho original dele.
- **Sprites do combo de sabre do Zero no estilo X4:** **[kensuyjin33](https://www.deviantart.com/kensuyjin33/gallery)**, conforme os créditos do pacote original.
- **Conceito, direção do projeto e testes:** **GmasterX / GMXzeroprogrammer**.
- **Apoio na programação:** **Claude (Anthropic)**, conforme os créditos do projeto original.

Esta é uma modificação de fã, não comercial e não oficial. Não é afiliada à Capcom, ao Justin3009 nem ao autor dos sprites. Os créditos não representam uma licença ou endosso. Respeite os direitos dos autores originais ao distribuir ou reutilizar o projeto.

## Atualização em desenvolvimento v1.8b

- **Cima + Y (no chão):** novo ataque ascendente do sabre de Zero, inspirado no Ryuenjin.
- A v1.8 corrige o funcionamento da barra roxa de vida dos chefes, incluindo dano, fraquezas e intervalos de invencibilidade.
- As versões v1.7c até v1.7k também trouxeram melhorias nas trocas de personagens durante chefes, armas especiais, Boss Rush e estabilidade.
- **Atenção:** os patches v1.8b ainda não foram publicados aqui. Os arquivos IPS disponíveis são da v1.7b.

[Página do projeto](docs/index.html)
