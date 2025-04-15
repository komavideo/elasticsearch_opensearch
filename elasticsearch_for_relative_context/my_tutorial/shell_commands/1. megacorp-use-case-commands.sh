## 以下所有命令均在kibana开发工具控制台上执行
## 以下命令用于megacorp用例
# http://192.168.0.111:5601/app/dev_tools#/console

PUT /megacorp

POST /megacorp/_doc
{
    "id": 1,
    "type": "employee",
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}

POST /megacorp/_doc
{
    "id": 2,
    "type": "employee",
    "first_name" :  "Jane",
    "last_name" :   "Smith",
    "age" :         32,
    "about" :       "I like to collect rock albums",
    "interests":    [ "music" ]
}

POST /megacorp/_doc
{
    "id": 3,
    "type": "employee",
    "first_name" :  "Douglas",
    "last_name" :   "Fir",
    "age" :         35,
    "about":        "I like to build cabinets",
    "interests":    [ "forestry" ]
}

GET /megacorp/_mapping


GET /megacorp/_doc/DXxZ3JEBOmmSC0uoyg14 # 这是文档的_id（由Elasticsearch自动生成）

GET /megacorp/_source/DXxZ3JEBOmmSC0uoyg14 # 获取_source字段，即原始文档输入

GET /megacorp/_search

GET /megacorp/_search
{
    "query": {
        "match": {
            "last_name": "Smith"
        }
    }
}

HEAD /megacorp/_source/DXxZ3JEBOmmSC0uoyg14 # 检查文档是否存在

# 存储字段
# stored_fields仅在索引创建时起作用。如果索引已创建，则不起作用。
# 在现代版本的Elasticsearch中，_source过滤或docvalue_fields更适合检索特定字段。
PUT megacorp_new
{
   "mappings": {
       "properties": {
          "age": {
             "type": "integer",
             "store": false
          }
       }
   }
}

POST /megacorp_new/_doc
{
    "id": 1,
    "type": "employee",
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "new_field":   "I am a new field",
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}

GET /megacorp_new/_source/E3yD3JEBOmmSC0uoOg2R?stored_fields=age # 不应返回或异常

# 源过滤
GET megacorp/_source/DXxZ3JEBOmmSC0uoyg14/?_source_includes=last_name,first_name # 仅包含这些字段
GET megacorp/_source/DXxZ3JEBOmmSC0uoyg14/?_source_includes=last_name,first_name&_source_excludes=about # 排除about字段

# 更新现有索引的映射 - 会导致异常
# 你不能直接修改索引中现有字段的映射
# 要更改现有字段映射，你需要：
#   - 创建一个具有更新映射的新索引
#   - 将数据从旧索引重新索引到新索引
#   - 更新别名以指向新索引
# 但你可以添加新字段
PUT /megacorp
{
    "mappings": {
      "properties": {
        "last_name": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "text",
              "ignore_above": 256
            }
          }
        }
      }
}
}

# 简易搜索
GET /megacorp/_search
GET /megacorp/_search?q=last_name:Smith

# 首先，我们不再使用查询字符串参数，而是使用请求体。
# https://www.elastic.co/guide/en/elasticsearch/guide/2.x/_search_with_query_dsl.html

# 查询DSL
# 简易搜索有自身限制
GET /megacorp/_search
{
    "query" : {
        "match" : {
            "last_name" : "Smith"
        }
    }
}

GET /megacorp/_search
{
    "query" : {
        "match_phrase" : {
            "last_name" : "smith"
        }
    }
}

GET /megacorp/_search
{
    "query" : {
        "match" : {
            "last_name" : "mith"
        }
    }
}

GET /megacorp/_search
{
    "query" : {
        "bool" : {
            "must" : {
                "match" : {
                    "last_name" : "smith" 
                }
            },
            "filter" : {
                "range" : {
                    "age" : { "gt" : 30 } 
                }
            }
        }
    }
}

# 全文搜索
GET /megacorp/_search
{
    "query" : {
        "match" : {
            "about" : "rock climbing"
        }
    }
}

# 短语搜索
GET /megacorp/_search
{
    "query" : {
        "match_phrase" : {
            "about" : "rock climbing"
        }
    }
}

# 高亮显示 - "I love to go <em>rock climbing</em>"
GET /megacorp/_search
{
    "query" : {
        "match_phrase" : {
            "about" : "rock climbing"
        }
    },
    "highlight": {
        "fields" : {
            "about" : {}
        }
    }
}

# 聚合
#     "caused_by": {
# "type": "illegal_argument_exception",
# "reason": "Fielddata在[megacorp]的[interests]上被禁用。
# 文本字段未针对需要按文档字段数据的操作（如聚合和排序）进行优化，因此这些操作默认被禁用。
# 请改用keyword字段。或者，在[interests]上设置fielddata=true以通过反转倒排索引来加载字段数据。请注意，这可能会使用大量内存。",
# }

GET /megacorp/_search
{
  "aggs": {
    "all_interests": {
      "terms": { "field": "interests" }
    }
  }
}

# 改为执行以下操作
PUT /megacorp_new
{
    "mappings": {
      "properties": {
        "interests": {
          "type": "keyword"
        }
      }
}
}

POST /megacorp_new/_doc
{
    "id": 1,
    "type": "employee",
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}

POST /megacorp_new/_doc
{
    "id": 2,
    "type": "employee",
    "first_name" :  "Jane",
    "last_name" :   "Smith",
    "age" :         32,
    "about" :       "I like to collect rock albums",
    "interests":    [ "music" ]
}

POST /megacorp_new/_doc
{
    "id": 3,
    "type": "employee",
    "first_name" :  "Douglas",
    "last_name" :   "Fir",
    "age" :         35,
    "about":        "I like to build cabinets",
    "interests":    [ "forestry" ]
}

GET /megacorp_new/_search
{
  "aggs": {
    "all_interests": {
      "terms": { "field": "interests" }
    }
  }
}

GET /megacorp_new/_search
{
  "aggs": {
    "all_interests": {
      "terms": { "field": "interests" }
    }
  }
}

## 输出查看

"aggregations": {
"all_interests": {
    "doc_count_error_upper_bound": 0,
    "sum_other_doc_count": 0,
    "buckets": [
    {
        "key": "music",
        "doc_count": 2
    },
    {
        "key": "forestry",
        "doc_count": 1
    },
    {
        "key": "sports",
        "doc_count": 1
    }
    ]
}
}

# 我们可以看到两名员工对音乐感兴趣，一名对林业感兴趣，一名对体育感兴趣。
# 这些聚合不是预先计算的；它们是根据当前查询匹配的文档即时生成的。
# 如果我们想了解姓Smith的人的兴趣爱好，我们只需在组合中添加适当的查询

GET /megacorp_new/_search
{
  "query": {
    "match": {
      "last_name": "smith"
    }
  },
  "aggs": {
    "all_interests": {
      "terms": {
        "field": "interests"
      }
    }
  }
}

# 聚合还允许层次化汇总。
# 例如，让我们找出拥有特定兴趣的员工的平均年龄：

GET /megacorp/_search
{
    "aggs" : {
        "all_interests" : {
            "terms" : { "field" : "interests" },
            "aggs" : {
                "avg_age" : {
                    "avg" : { "field" : "age" }
                }
            }
        }
    }
}

## 集群健康状态
# green: 所有主分片和副本分片都处于活动状态。
# yellow: 所有主分片都处于活动状态，但并非所有副本分片都处于活动状态。（因此单节点集群将始终为黄色）。一旦开始添加更多节点，集群将变为绿色。
# red: 不是所有主分片都处于活动状态。

# 索引与分片
# 索引是具有相似特征的文档集合。
# 分片是仅保存索引中所有数据一部分的低级工作单元。

# 默认情况下，索引被分配五个主分片

GET /_cluster/health

GET /_cat/indices?v

# 索引与分片
# 增加混乱的是，Lucene索引在Elasticsearch中被称为分片，
# 而Elasticsearch中的索引是分片的集合。当Elasticsearch搜索索引时，
# 它将查询发送到属于该索引的每个分片（Lucene索引）的副本，
# 然后将每个分片的结果减少为全局结果集

# 分片是Elasticsearch在集群中分配数据的方式。
# 将分片视为数据容器。文档存储在分片中，
# 分片分配给集群中的节点。随着集群的增长或收缩，
# Elasticsearch会自动在节点之间迁移分片，以保持集群平衡。

# 分片可以是主分片或副本分片。
# 索引中的每个文档都属于单个主分片，
# 因此你拥有的主分片数量决定了索引可以容纳的最大数据量

# 索引中的主分片数量在创建索引时是固定的，
# 但副本分片的数量可以随时更改。

# refresh API
# 默认情况下，每个分片每秒自动刷新一次。
# 这就是为什么我们说Elasticsearch具有近实时搜索：文档更改不会立即对搜索可见，
# 但会在1秒内变得可见。
# 不建议在生产环境中进行手动刷新

POST /_refresh 
POST /megacorp/_refresh 

# 你的用例可能允许较低的刷新率
PUT /megacorp/_settings
{
  "settings": {
    "refresh_interval": "30s" 
  }
}
