---
paths: "**/*.ts", "**/*.tsx", "**/*route*.ts", "**/*api*.ts"
---

# Hono Routing Corrections

Claude's training may suggest Express patterns. This project uses **Hono v4**.

## Response: c.json(), Not res.send()

```typescript
/* ❌ Express pattern */
app.get('/api/users', (req, res) => {
  res.send({ users })
  res.json({ users })
})

/* ✅ Hono pattern */
app.get('/api/users', (c) => {
  return c.json({ users })
  // Also: c.text(), c.html(), c.body()
})
```

## Middleware: MUST await next()

```typescript
/* ❌ Breaks middleware chain */
app.use(async (c, next) => {
  console.log('Before')
  next() // Missing await!
  console.log('After')
})

/* ✅ Always await next() */
app.use(async (c, next) => {
  console.log('Before')
  await next() // Required!
  console.log('After')
})
```

## Params: c.req.param(), Not req.params

```typescript
/* ❌ Express pattern */
app.get('/users/:id', (req) => {
  const id = req.params.id
})

/* ✅ Hono pattern */
app.get('/users/:id', (c) => {
  const id = c.req.param('id')
  // Or get all: c.req.param()
})
```

## Validation: Use Validator Middleware

```typescript
/* ❌ Raw request access */
app.post('/users', async (c) => {
  const body = await c.req.json() // No validation!
})

/* ✅ Use validator middleware */
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const schema = z.object({ name: z.string(), email: z.string().email() })

app.post('/users', zValidator('json', schema), (c) => {
  const body = c.req.valid('json') // Type-safe and validated!
})
```

## Error Handling: HTTPException

```typescript
/* ❌ Plain Error doesn't set status */
throw new Error('Not found')

/* ✅ Use HTTPException */
import { HTTPException } from 'hono/http-exception'
throw new HTTPException(404, { message: 'User not found' })
```

## RPC: Export Route, Not App

```typescript
/* ❌ Exporting entire app causes IDE slowdown */
export type AppType = typeof app

/* ✅ Export specific route groups */
const userRoutes = app.get('/users', handler).post('/users', handler)
export type UserRoutes = typeof userRoutes
```

## Type Variables for c.set/c.get

```typescript
/* ❌ No type safety */
c.set('user', user)
const user = c.get('user') // any

/* ✅ Define Variables type */
type Variables = { user: User }
const app = new Hono<{ Variables: Variables }>()
c.set('user', user) // Type-checked
const user = c.get('user') // User type
```

## Quick Fixes

| Express pattern | Hono equivalent |
|----------------|-----------------|
| `res.send()` / `res.json()` | `c.json()` / `c.text()` |
| `req.params.id` | `c.req.param('id')` |
| `req.body` | `c.req.valid('json')` with validator |
| `next()` | `await next()` |
| `throw new Error()` | `throw new HTTPException(status)` |
