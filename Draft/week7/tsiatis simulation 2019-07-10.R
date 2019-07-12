# 2019-07-10

# tsiatis example simulation 

library(survival)
library(png)
library(grid)



### functions
ftc = function(t,c){
  return((lambda * mu - theta + lambda * theta * t + 
            mu * theta * c + theta^2 * t * c )* exp( - lambda * t - mu * c - theta * t * c))
}

ft = function(t){
  return(lambda * exp(- lambda * t))
}

St = function(t){
  return(exp(-lambda * t))
}
Sx = function(t){
  return(exp(-lambda * t - mu * t - theta * t^2))
}

psi = function(t){
  return((lambda + theta * t) * exp(- lambda * t - mu * t - theta * t^2))
}

rho = function(t){
  return((ft(t)/psi(t) - 1) / (St(t)/Sx(t) - 1))
}

ni = function(i){
  X = sort(data$time)
  id = which(X == Xd[i])[1]
  return(length(X) - id + 1)
}

ci = function(i){
  xi = Xd[i]
  xi1 = Xd[i + 1]
  temp = data[data$time > xi & data$time< xi1,] ## < or <=?
  return(sum(temp$status == 0))
}

part2_version1 = function(t){
  # slud's function 
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  if(dt == 0){
    temp = 0
  }else{
    for(k in 0:(dt - 1)){
      temp2 = 1
      for(i in (1+k):dt){
        xd = Xd[i]
        if(Xd[i] == 0){xd = 10e-10}
        part3 = ni(i) - 1 + rho(xd)
        if(part3 == 0){
          part3 = 10e-10
        }
        temp2 = temp2 *  (1 - min(part3/(part3+3), rho(xd)/part3)) 
      }
      temp = temp + ci(k) * temp2
    }
  }
  return(temp /N)
}

part2_version2 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  if(dt == 0){
    temp = 0
  }else{
    temp2 = ci(dt - 1)
    if(dt < 2){
      temp = 0 
    }else{
      for(k in 0:(dt - 2)){
        temp3 = 1
        for(i in (1+k):(dt-1)){
          part3 = ni(i)
          if(part3 == 0){
            part3 = 10e-10
          }
          xd = Xd[i]
          if(xd == 0){xd = 10e-10}
          temp3 = temp3 * (1 - min(part3/(part3+3), rho(xd)/part3))
        }
        temp = temp + ci(k) * temp3
      }
    }
    temp = temp + temp2
  }
  return(temp /N)
}

Spt = function(t){
  N = dim(data)[1]
  nt = sum(data$time > t)
  
  part1 = 1/N * nt 
  s11 = part1
  
  s1 = part1 + part2_version1(t)
  s2 = part1 + part2_version2(t)

  return(list(s1 = s1, s2 = s2, s11 = s11))
}

### parameter settings
lambda = 0.1
mu = 0.2
theta = 0.02

# lambda = 1
# mu = 1
# theta = 1

### plot of rho
rho_test = c()
for(i in seq(0,40,1)){
  rho_test = c(rho_test, rho(i))
}
plot(seq(0,40,1), rho_test, type = 'l', ylab= expression(rho), xlab = 'x', main ='Range of rho')

### generate data
set.seed(123)  
Cc = rep(seq(0,40,0.001), each = 100)
Tt = rep(seq(0,40,0.001), 100)
Prob = ftc(Tt, Cc)
grid_data = data.frame(subj = 1:length(Prob), t = Tt, c = Cc, p = Prob) 
head(grid_data)

N = 500
sample_data = sample(1:length(grid_data$p), size = N, prob = grid_data$p, replace = TRUE)

# sampled data 
data = grid_data[sample_data,] 
data = data.frame(deathtime = data$t, censortime = data$c, status = (data$c > data$t))
data$time = ifelse(data$status == 1, data$deathtime, data$censortime)
data$status = ifelse(data$status == TRUE, 1, 0)
data = round(data,4)
data = data[data$time %in% as.numeric(names(which(table(data$time) > 1))) == FALSE,]
length(unique(data$time))
dim(data)
data = data[order(data$time),]
rownames(data) = NULL

# censor rate
round(sum(data$status)/dim(data)[1],3)

# get death time
X = sort(data$time)
d = sum(data$status == 1)
data_death = data[data$status == 1, ]; rownames(data_death) = NULL
Xd = data_death$time
length(Xd)
true_rou_values = rho(Xd) # the true rho values 

# KM
fit1 = survfit(Surv(time, status) ~ 1, data=data)
plot(fit1$time, fit1$surv, type = 'l')
lines(fit1$time, St(fit1$time), col =2)

# slud's function  
s1 = c(); s2 = c(); s11 = c()
for(t in data$time){
  res = Spt(t)
  s11 = c(s11, res$s11)
  s1 = c(s1, res$s1)
  s2 = c(s2, res$s2)
}

# plot
plot(fit1$time, fit1$surv, type = 'l', ylab='S(t)', xlab = 'time',
     main = paste('lambda = ',lambda, '; mu = ', mu, '; theta = ', theta, sep =''))
lines(fit1$time, St(fit1$time), col =3, lty = 2)
lines(data$time, s1, col = 4, lty =3)
lines(data$time, s3, col = 6, lty = 4)
legend('topright',legend = c('KM S(t)','True S(t)', 'Slud','corrected Slud'), col = c(1,3,4,6), lty = 1:4)

nplot = 400
mean(abs(fit1$surv - St(fit1$time))[nplot])
mean(abs(St(data$time) - s1)[nplot])
mean(abs(St(data$time) - s2)[nplot])


# part1 part2 difference 
A_part = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nis = ni(dt - 1)
  res = 1 - (nis - 1) * nis / ((nis - 1) * nis + 0.5 - 0.5^2)
  return(res)
} 
Amax = c()
for(t in data$time){
  Amax = c(Amax, A_part(t))
}
max(Amax, na.rm=TRUE)
