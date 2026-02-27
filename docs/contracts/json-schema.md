# JSON Output Contracts

## search (`sgd search ... --json`)

Returns an array of objects:

```json
[
  {
    "title": "string",
    "url": "string",
    "snippet": "string",
    "source": "android|kotlin|jetpack",
    "score": 1.0
  }
]
```

## doc (`sgd doc ... --json`)

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

## frameworks (`sgd frameworks --json`)

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
