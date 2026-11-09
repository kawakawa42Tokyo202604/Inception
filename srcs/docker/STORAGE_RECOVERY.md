# Dockerストレージの復旧

Dockerの保存先 `/home/student/data/docker` が削除された後、デーモンを起動したままビルドすると、`docker/tmp` が見つからないなどのエラーが起こることがあります。

Recovery behavior when the configured Docker data directory has been removed.

## 自動復旧の条件

`make`・`make build`・`make backup`・`make restore-check` は、最初に保存先を確認します。保存先がなく、次の条件が揃うとDockerを一度再起動してディレクトリを再作成します。

- Dockerのdata-rootが設定された保存先と一致する。
- 接続先がVM内のシステムDockerソケットである。
- 起動中・停止中のコンテナが1つも残っていない。
- systemdのDockerサービスが稼働しており、管理ヘルパーを使えるかrootで実行している。

ヘルパーの導入方法は [VMの初期設定](../../DEV_DOC.md#vm-setup) にあります。

## 復旧と確認

Inception のルートで実行します。

```sh
make
make check-config
make ps
```

保存先が正常に存在する場合は、通常のビルド・起動へ進みます。`make check-config` は読み取り専用の確認です。

復旧時は、残っている環境ファイルとsecretを使ってサイトを新規初期化します。削除された記事・DB・バックアップを戻すには、別途保管したバックアップが必要です。保存先内部の部分的な破損は自動修復しません。

## 復旧できない場合

| 原因 | 対応 |
| --- | --- |
| Dockerの保存先が違う | デーモン設定とMakeの `DATA_DIR` を確認 |
| コンテナが残っている | 対象とデータの状態を管理者が確認 |
| ヘルパーの権限がない | 開発者ガイドの初回設定を確認 |
| Dockerサービスが停止している | VM管理者がサービスを起動 |

復旧の判定と失敗時の動作は、`make test` のモックテストで確認できます。
