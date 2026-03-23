const { z } = require('zod'); exports.createNote = z.object({ title: z.string().min(1) });
