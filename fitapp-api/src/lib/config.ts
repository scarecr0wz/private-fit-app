if (!process.env.JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable must be set before starting the server')
}

export const JWT_SECRET = process.env.JWT_SECRET
