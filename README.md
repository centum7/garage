# Garage
[![Build Status](https://travis-ci.org/cookpad/garage.svg?branch=master)](https://travis-ci.org/cookpad/garage)

Rails framework to add RESTful hypermedia API to your application.

## What Is It?

Garage provides a simple, Hypermedia friendly RESTful API to your Rails application using its native RESTful routes. Garage provides a descriptive way to serve your ActiveRecord models, as well as plain old Ruby objects as JSON-based resources.

Garage supports OAuth 2 authorizations via Doorkeeper (more extensions to come), and provides resource-based access controls.

## Quickstart

In `Gemfile`:

```ruby
gem 'garage', github: 'cookpad/garage'
```

In your Rails model class:

```ruby
class Employee < ActiveRecord::Base
  include Garage::Representer

  belongs_to :division
  has_many :projects
  property :id
  property :title
  property :first_name
  property :last_name

  property :division, selectable: true
  collection :projects, selectable: true

  link(:division) { division_path(division) }
  link(:projects) { employee_projects_path(self) }

  def self.build_permissions(perms, other, target)
    perms.permits! :read
  end
end
```

In your controller class:

```ruby
class EmployeesController < ApplicationController
  include Garage::RestfulActions

  def require_resources
    @resources = Employee.all
  end
end
```

## Advanced Configurations

In `config/initializers/garage.rb`:

```ruby
Garage.configure {}

# Optional
Garage::TokenScope.configure do
  register :public, desc: "accessing publicly available data" do
    access :read, Recipe
  end

  register :read_post, desc: "reading blog post" do
    access :read, Post
  end
end

# If you want to use different authentication/authorization logic.
Garage.configuration.strategy = Garage::Strategy::AuthServer
```

The following authentication strategies are available.

- `Garage::Strategy::NoAuthentication` - 
    リクエストを認証せず、リソースオペレーションに許可を与えない。
    これは、公表されていない内部用のガレージアプリケーションのためのもの
- `Garage::Strategy::Test` - テストやプロトタイプのためのもの。 リクエストを完全に信用し、リクエストヘッダーからアクセストークンを作る。
- `Garage::Strategy::Doorkeeper` -doorkeeperでリクエストを承認する。
   このStrategyを使うためには [garage-doorkeeper gem](https://github.com/cookpad/garage-doorkeeper)をbundle installする。
- `Garage::Strategy::AuthServer` -
    認証をOAuthサーバーに委任する。このStrategyは設定を持っている。


## Delegate Authentication/Authorization to your OAuth server



#####To delegate auth to your OAuth server, use `Garage::Strategy::AuthServer` strategy.
Then configure auth server strategy:

- `Garage.configuration.auth_server_url` - OAuthサーバーのアクセストークンのバリデーションエンドポイントのURLそのもの。`https://example.com/token`

- `Garage.configuration.auth_server_host` -OAuthサーバーのホストのヘッダーvalue。空欄でもOK。
- `Garage.configuration.auth_server_timeout` - 読み込みのタイムアウトの時間（秒）。デフォルト設定では1秒となっている。
    is 1 second.

The OAuth server must response a json with following structure.

- `token`(string) - アクセストークンの値.
- `token_type` (string) - アクセストークンvalue。 例：`bearer` type.
- `scope` (string) -スペースで区切られたscope。例： `public read_user`.
- `application_id` (integer) - アクセストークンのアプリケーションid。
- `resource_owner_id` (integer, null) -アクセストークンのリソースオーナーid。
- `expired_at` (string, null) - 文字列で表示された、期限のdatetime。
- `revoked_at` (string, null) - 文字列で表示された、無効になった時のdatetime。

When requested access token is invalid, OAuth server must response 401.

## Customize Authentication/Authorization　　




Garage は、カスタマイズ可能なStrategyを提供しています。以下のような慣習があります。


- access_tokenメソッドを使って、OAuthアクセストークンを提供する。アクセストークンが無い場合やリクエストが認証されない時はaccess_tokenはnilを返す。
- 含まれているブロックの中のfilterの前で、verify_auth hookを登録する。もしくはカスタム認証hookを登録する。リクエストが認証されなかった場合、カスタム認証hookは、unauthorized_render_optionsを使って非認証を返す。
- RestfulAction内で、verify_permissionメソッドを使って認証とアクセスを提供する。

```ruby
module MyStrategy
  extend ActiveSupport::Concern

  included do
    # Register verify_auth hook if you want to authenticate request.
    before_action :verify_auth
  end

  def access_token
    # Fetch some `attributes` from DB or auth server API using request.
    # Then returns an AccessToken with caching.
    @access_token ||= Garage::Strategy::AccessToken.new(attributes)
  end

  # Whether verify permission and access in `RestfulActions`.
  def verify_permission?
    true
  end
end
```

## Authors

* Tatsuhiko Miyagawa
* Taiki Ono
* Yusuke Mito
* Ryo Nakamura

## Inspired By

* [roar](https://github.com/apotonick/roar)
* [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)
