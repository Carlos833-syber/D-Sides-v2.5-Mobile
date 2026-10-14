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

## Controles

- Menus: setas na parte inferior, **OK** confirma e **BACK** volta.
- Música: quatro colunas de toque, na ordem esquerda, baixo, cima e direita.
  Segure para notas longas; múltiplos dedos são aceitos.
- **PAUSE** abre o menu de pausa; use **OK** para selecionar a opção de retomar.
- Diálogos e tela de derrota usam **OK** e **BACK**.
- Teclado e controle físico continuam disponíveis. Para controle físico, ative
  _Controller Mode_ em _Gameplay_.
- A configuração de teclas foi ocultada no Android; os controles de toque são fixos.

Músicas e cenários são carregados por biblioteca quando necessários, em vez de
pré-carregar todas as semanas na inicialização. Os arquivos empacotados são lidos
pela API de assets do OpenFL/Lime, sem exigir acesso ao armazenamento compartilhado.
O pacote Android é `com.carlos833.dsides`.

O template local em `templates/android/template/app/src/main/AndroidManifest.xml`
parte do Lime 7.9.0 e declara `android:exported="true"` na `MainActivity`, que tem
o filtro `MAIN`/`LAUNCHER`. Isso permite instalar e abrir o APK em Android 12 ou
superior com o SDK alvo 33. O arquivo é registrado como template individual com
`rename="app/src/main/AndroidManifest.xml"`: o Lime o aplica depois dos templates
padrão, evitando que a versão sem `exported` prevaleça. Ao atualizar o Lime,
revise também esse template.

Antes do upload, o workflow extrai o manifesto do APK com `apkanalyzer` e executa
`scripts/verify-android-manifest.py`. A execução falha se a atividade do launcher
não tiver `android:exported="true"` ou se algum componente com filtro de intents
não declarar um valor explícito para `exported`.

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
