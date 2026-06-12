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

# Kaynak kodları kopyala
COPY . .

# (Eğer derleme gerekmiyorsa bu satırı SİL veya yorum satırı yap)
# RUN npm run build

# 2. Aşama: Çalıştırma ortamı
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma
# Derleme yoksa tüm klasörü kopyala
COPY --from=builder /app ./ 

EXPOSE 5000
# Direkt index.js'i çalıştır
CMD ["node", "index.js"]