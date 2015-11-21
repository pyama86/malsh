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
$ export MACKEREL_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxx

$ sac retire --subject 退役忘れホスト

$ sac develop --words dev local --subject developmentホスト

$ sac maverick --subject 無所属ホスト
```

## options
* --slack-webhook
slackのwebhookurlを指定するとslackに通知することができます。
* --slack-channel
slackの通知先チャネルを指定します。
* --api-key
mackerelのAPIキーを指定します。
環境変数`MACKEREL_KEY`に設定することでも同等の挙動をします。

## Author
pyama86
