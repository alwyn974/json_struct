# Json Struct

Transform a json file into a struct.

## Options

- `--output/-o`: Output file.
- `--input/-i`: Input file.
- `--typedef/-t`: Whether to use typedef.

## Example

Input
```json
{
  "user": {
    "name": "char *",
    "uuid": "uuid_t",
    "created_at": "time_t",
    "some_value": "some_type"
  }
}
```

Output
```c
typedef struct {
    char *name;
    uuid_t uuid;
    time_t created_at;
    some_type some_value;
} user_t;
```
