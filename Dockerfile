# 1. Aşama: Build ortamı
FROM node:18-alpine AS builder

# Gerekli kütüphaneleri yükle
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Bağımlılıkları yükle
COPY package*.json ./
RUN npm install

# Prisma'yı hazırla
COPY prisma ./prisma/
RUN npx prisma generate

# Kaynak kodları kopyala ve build al
COPY . .
RUN npm run build

# 2. Aşama: Çalıştırma ortamı (Production)
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

# Sadece gerekli dosyaları kopyala
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma

# Uygulamayı başlat
EXPOSE 5000
CMD ["node", "dist/index.js"]