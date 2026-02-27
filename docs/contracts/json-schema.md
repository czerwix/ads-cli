# JSON Output Contracts

## search (`ads search ... --json`)

Returns an array of objects:

```json
[
  {
    "title": "string",
    "url": "string",
    "snippet": "string",
    "source": "string",
    "sourceId": "string",
    "kind": "unknown|reference|guide|tutorial|sample",
    "official": true,
    "score": 1.0
  }
]
```

## doc (`ads doc ... --json`)

Returns one object:

```json
{
  "title": "string",
  "url": "string",
  "summary": "string",
  "sections": [{ "title": "string", "body": "string" }],
  "codeBlocks": ["string"],
  "relatedLinks": [{ "title": "string", "url": "string" }],
  "metadata": { "string": "string" }
}
```

## related (`ads related ... --json`)

Returns an array of objects:

```json
[
  {
    "title": "string",
    "url": "string",
    "snippet": "",
    "source": "related",
    "sourceId": "related",
    "kind": "unknown",
    "official": false,
    "score": 1.0
  }
]
```

## platform (`ads platform ... --json`)

Returns an object map of platform metadata keys and values:

```json
{
  "androidApiLevel": "21",
  "artifact": "androidx.lifecycle:lifecycle-viewmodel"
}
```

## frameworks (`ads frameworks --json`)

Returns an array:

```json
[
  {
    "name": "string",
    "slug": "string",
    "description": "string"
  }
]
```

## sources (`ads sources --json`)

Returns an array:

```json
[
  {
    "id": "android",
    "displayName": "Android Developers",
    "kind": "reference",
    "official": true
  }
]
```
