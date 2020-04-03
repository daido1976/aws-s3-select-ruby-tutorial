require 'aws-sdk-s3'
require 'csv'

s3_client = Aws::S3::Client.new(region: 'ap-northeast-1')

bucket = 's3-select-sample'
key = 'target_sample_users.csv'

# サンプル用のデータを準備する
s3_client.put_object(bucket: bucket, key: key, body: File.read('sample_users.csv'))

# 与えられた ids 配列の id で検索し、id と name だけ抽出するクエリを作成する
def build_query(ids)
  <<~QUERY
    SELECT
    s.id
    , s.name
    FROM S3Object s
    WHERE s.id
    IN ('#{ids.join("', '")}')
  QUERY
end

# `#select_object_content` に渡すパラメータを作成する
def build_params(bucket, key, query)
  {
    bucket: bucket,
    key: key,
    expression_type: 'SQL',
    expression: query,
    input_serialization: {
      # field_delimiter を "\t" にすることでタブ区切りのファイルにも対応可能
      csv: { file_header_info: 'USE', allow_quoted_record_delimiter: true, record_delimiter: "\n", field_delimiter: ',' }
    },
    output_serialization: {
      csv: { record_delimiter: "\n", field_delimiter: ',' }
    }
  }
end

# id が 1 と 50 のユーザを検索する
query = build_query([1, 50])
params = build_params(bucket, key, query)

# S3 Select を使ってレスポンスを取得する
response = s3_client.select_object_content(params)

# `#event_type == :records` の中にレコード（抽出されたデータ）が含まれる
csv_list = response.payload.select { |p| p.event_type == :records }.map(&:payload).map(&:read)
csv = CSV.parse(csv_list.join)

# マルチバイト文字列を扱う場合
csv.map do |row|
  row.map { |r| r.force_encoding('UTF-8') }
end

p csv
