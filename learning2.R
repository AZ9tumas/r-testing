a <- list(
    data.frame(a = 1:10, b = 11:20, frame = 1:10),
    data.frame(a = 21:30, b = 31:40, frame = 11:20),
    data.frame(a = 41:50, b = 51:60, frame = 21:30)
)

df <- rbindlist(a)
df

cbind(df[1:2])
