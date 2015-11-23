# Sac

[![Build Status](https://travis-ci.org/pyama86/sac.svg)](https://travis-ci.org/pyama86/sac)

[![Code Climate](https://codeclimate.com/github/pyama86/sac/badges/gpa.svg)](https://codeclimate.com/github/pyama86/sac)

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
* --slack-webhook or ENV["SLACK_WEBHOOK"]

slackのwebhookurlを指定するとslackに通知することができます。
* --slack-channel or ENV["SLACK_CHANNEL"]

slackの通知先チャネルを指定します。
* --slack-user or ENV["SLACK_USER"]

slackの通知ユーザーを指定します。
* --api-key or ENV["MACKEREL_APIKEY"]

mackerelのAPIキーを指定します。
* --subject

通知のタイトルを指定します
* --invert-match

除外したいホスト名を正規表現で指定します。

## Author
pyama86
