# Sac

### mackerelの運用で便利な下記の機能を提供します。

* 退役忘れホストの検知
* developmentっぽいホストの検知
* ロールに紐付いてないホストの検知

### 通知機能
* Slackへの通知

## Installation

```ruby
gem install sac
```

## Usage

```sh
$ export MACKEREL_APIKEY=xxxxxxxxxxxxxxxxxxxxxxxxxx

# 過去5分間メトリックの投稿がないホストを検知
$ sac retire --subject 退役忘れホスト

# 指定された単語がホスト名に含まれるホストを検知
$ sac find --regex dev local$ --subject developmentホスト

# ロールに所属していないホストを検知
$ sac maverick --subject 無所属ホスト
```

## options
* --slack-webhook
slackのwebhookurlを指定するとslackに通知することができます。
* --slack-channel
slackの通知先チャネルを指定します。
* --api-key
mackerelのAPIキーを指定します。
環境変数`MACKEREL_APIKEY`に設定することでも同等の挙動をします。
* --subject
通知のタイトルを指定します
* --invert-match
除外したいホスト名を正規表現で指定します。

## Author
pyama86
