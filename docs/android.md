# D-Sides 2.5 para Android

Port baseado no commit `174ba9532daee9f3f2034c4bc910ed72776c51e0` de
[Carlos833-syber/D-Sides-v2.5-Mobile](https://github.com/Carlos833-syber/D-Sides-v2.5-Mobile).

## Compilar

Ferramentas: Haxe **4.2.5**, Neko **2.3.0** (64 bits no Linux), JDK **11**,
Android SDK **33**, build-tools **33.0.2**, NDK **21.4.7075529**.
`mise.toml` declara Haxe e JDK. Instale Neko separadamente e configure o Haxelib:

```bash
haxelib setup /caminho/para/haxelib
bash scripts/setup-haxelib.sh
export JAVA_HOME=/caminho/para/jdk-11
export ANDROID_HOME=/caminho/para/android-sdk
bash scripts/build-android.sh
```

O script compila ARMv7 e ARM64. O APK fica em
`export/release/android/bin/app/build/outputs/apk/debug/DSides-debug.apk`.
Sem uma chave de distribuição configurada, o APK usa a assinatura de desenvolvimento
para instalação local. Não é uma publicação na Play Store.

O projeto usa Lime 7.9.0, OpenFL 9.2.1, Flixel 4.11.0, flixel-addons 2.11.0,
flixel-ui 2.5.0, hscript 2.5.0 e hxcpp 4.2.1.
As bibliotecas nativas Android do Lime já acompanham sua distribuição Haxelib.

## Compilar pelo GitHub Actions

O workflow **Android APK** (`.github/workflows/android.yml`) executa em pushes e
pull requests para `main`. Para iniciar manualmente após integrar o workflow na
branch padrão:

1. Abra **Actions → Android APK → Run workflow** no GitHub.
2. Escolha a branch e confirme **Run workflow**.
3. Aguarde o job **Build ARMv7 + ARM64 APK** terminar.
4. Baixe `DSides-Android-<número da execução>` em **Artifacts**, extraia o ZIP e
   instale o APK no aparelho.

O artefato fica disponível por 14 dias. Ele contém um APK de desenvolvimento
com as duas arquiteturas; não exige secrets de assinatura nem publica releases.
A chave de desenvolvimento é gerada no runner e pode mudar entre execuções:
se o Android recusar a atualização por assinatura diferente, será necessário
remover a instalação anterior (o que apaga seus dados locais).

A automação reutiliza `mise.toml`, `scripts/setup-haxelib.sh` e
`scripts/build-android.sh`. O SDK é instalado com Java 17, exigido pelas ferramentas
atuais do Android; a compilação do Lime usa o Java 11 declarado no projeto.
Falhas de compilação ficam nos logs do job; se nenhum APK for gerado, o upload
falha em vez de concluir sem um arquivo para download.

## Controles

- Menus: setas na parte inferior, **OK** confirma e **BACK** volta.
- Música: quatro colunas de toque, na ordem esquerda, baixo, cima e direita.
  Segure para notas longas; múltiplos dedos são aceitos.
- **PAUSE** abre o menu de pausa; use **OK** para selecionar a opção de retomar.
- Diálogos e tela de derrota usam **OK** e **BACK**.
- Teclado e controle físico continuam disponíveis. Para controle físico, ative
  *Controller Mode* em *Gameplay*.
- A configuração de teclas foi ocultada no Android; os controles de toque são fixos.

Músicas e cenários são carregados por biblioteca quando necessários, em vez de
pré-carregar todas as semanas na inicialização. Os arquivos empacotados são lidos
pela API de assets do OpenFL/Lime, sem exigir acesso ao armazenamento compartilhado.
O pacote Android é `com.carlos833.dsides`.

## Conteúdo disponível e limites

O repositório contém Tutorial e semanas 1–5 nos menus empacotados. Ele lista
`week6`, mas não fornece `assets/preload/weeks/week6.json`; o menu ignora essa entrada.
O código também referencia a música secreta `too-slow`, cujos áudios não estão presentes. Esses arquivos precisam ser fornecidos para incluir esse conteúdo.

Lua e vídeos não são habilitados no Android pela configuração original. Os scripts
empacotados das semanas 1 e 5, notas de Blammed, Flash Camera e o Hey de Bopeebo
foram adaptados para Haxe. JSONs de personagens/cenários e sprites de `example_mods`
são incluídos como assets internos. Scripts de mods externos,
cutscenes de vídeo e o editor de desktop exigem trabalho adicional para Android.

Há spritesheets de até 16384 × 4096 pixels no conteúdo original. Aparelhos com
limite de textura menor podem precisar de uma etapa adicional de divisão dos atlases;
as texturas não foram redimensionadas neste port.

A compilação não comprova desempenho nem sincronização de áudio em aparelhos reais.
Antes de distribuir, teste músicas, notas longas, multitouch, pausa/retomada,
salvamento e alternância entre o jogo e outros aplicativos em um aparelho Android.
