# frozen_string_literal: true

require 'aws-sdk-s3'
require 'csv'

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
      # field_delimiter を "\t" にすることでタブ区切りのファイルにも対応できます
      csv: { file_header_info: 'USE', allow_quoted_record_delimiter: true, record_delimiter: "\n", field_delimiter: ',' }
    },
    output_serialization: {
      csv: { record_delimiter: "\n", field_delimiter: ',' }
    }
  }
end

s3_client = Aws::S3::Client.new(region: 'ap-northeast-1')
bucket = 's3-select-sandbox'
key = 'sample_users.csv'

# Only once execute
# s3_client.create_bucket(bucket: bucket)
# s3_client.put_object(bucket: bucket, key: key, body: File.read('./tmp/test.csv'))

# Use #get_object
# response = s3_client.get_object(bucket: bucket, key: key)
# CSV.parse(response.body.read)

# Use #select_object_content (S3 Select)
query = build_query([1, 50])
params = build_params(bucket, key, query)
response = s3_client.select_object_content(params)

csv_list = response.payload.select { |p| p.event_type == :records }.map(&:payload).map(&:read)
csv = CSV.parse(csv_list.join)
csv.map do |row|
  row.map { |r| r.force_encoding('UTF-8') }
end

p csv
