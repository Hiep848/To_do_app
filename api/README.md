# To-Do App API

This API is built with Express.js and provides backend functionality for a To-Do App, supporting CRUD operations and advanced task management.

## Features

- Create, read, update, delete, and reorder to-do items
- Filter tasks by keyword or completion status
- RESTful endpoints with JSON responses
- Persistent storage using a local cache file

## Endpoints

| Method | Endpoint               | Description                                                 |
|--------|------------------------|-------------------------------------------------------------|
| GET    | `/todos`               | List all tasks, with optional filters (`q`, `status`)       |
| GET    | `/todos/:id`           | Get a specific task by ID                                   |
| POST   | `/todos`               | Create a new task                                           |
| PATCH  | `/todos/:id`           | Update fields of a task                                     |
| PATCH  | `/todos/reorder`       | Reorder tasks by index                                      |
| DELETE | `/todos/:id`           | Delete a specific task                                      |
| DELETE | `/todos`               | Delete all tasks                                            |

## Getting Started

1. Clone the repository.
2. Install dependencies (`npm install`).
3. Run the API server (`node server.js`).

## Example Request

```http
GET /todos
Content-Type: application/json

{
    "id": "5560f05e-40fa-43a6-860b-0b157ef49108"
    "title": "Buy groceries",
    "description": "Milk, eggs, bread"
    "isCompleted": false
    "lastModify": "2025-07-11T04:35:09.700Z" 
}
```

## License

MIT