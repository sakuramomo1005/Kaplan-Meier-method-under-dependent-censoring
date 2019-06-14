### 2019-06-13

# install.packages('km.ci')
library(survival)
library(km.ci)
########################################################################################

############# Example 1: fxy = (x + y)/1000

# generate data
set.seed(123)  
S = rep(seq(0,10,0.01), each = 1000)
tt = rep(seq(0,10,0.01), 1000)
P = 1/1000 * (S + tt)
grid_data = data.frame(subj = 1:length(P), s = S, t = tt, p = P) 
grid_data$p = grid_data$p/sum(grid_data$p)

N = 100
sample_data = sample(1:length(grid_data$p), size = N, prob = grid_data$p)
data = grid_data[sample_data,] 
data = data.frame(deathtime = data$s, censortime = data$t, status = (data$s< data$t))
data$time = ifelse(data$status == 1, data$deathtime, data$censortime)
data$status = ifelse(data$status == TRUE, 1, 0)
data = round(data,2)

# remove the duplicated 
# time duplicated
time_du = round(as.numeric(names(which(table(data$time)>1))),2)
death_du = round(as.numeric(names(which(table(data$deathtime)>1))),2)
data = data[(data$time %in% time_du) == FALSE, ]
data = data[(data$deathtime %in% death_du) == FALSE, ]
dim(data)
sum(table(data$time)>1)
sum(table(data$deathtime)>1)
data0 = data
data0$status = 1
data0$time = data0$deathtime
head(data)
dim(data)

# time X and death time Xd, 
X = sort(data$time)
data = data[order(data$time),]
rownames(data) = NULL
d = sum(data$status == 1)
data_death = data[data$status == 1, ]; rownames(data_death) = NULL
Xd = data_death$time

# functions 
rou = function(t){
  a = 3 * t * (1000 - 100 * t - 10 * t^2 + t^3)
  b = (100 + 20 * t -3 * t^2) * (50 + 5 * t - t^2)
  return(a/b)
}

f = function(t){
  return((10*t+50)/1000)
}

phi = function(t){
  return((50 + 10 * t - 3/2 * t^2)/1000)
}

S = function(t){
  return(1 - 1/1000 * (5 * t^2 + 50 * t))
}

plot(seq(0,10,0.1), S(seq(0,10,0.1)), type = 'l', main = 'S(t)')

Sx = function(t){
  return(1/1000 * (1000 - 100 * t - 10 * t^2 + t^3))
}

r = function(t){
  return((f(t)/phi(t) - 1)/(S(t)/Sx(t) - 1))
}

rou_values = rou(X)

Xj = function(j){
  return(Xd[j])
}
cj = function(j){
  if(j ==0){
    t1 = Xj(1)
    temp = temp = data[data$time <= t1, ]
    return(sum(temp$status == 0))
  }else{
    t1 = Xj(j)
    t2 = Xj(j+1)
    temp = data[data$time <= t2 & data$time >= t1, ]
    return(sum(temp$status == 0))
  }
}

nj = function(j){
  t1 = Xj(j)
  temp = data[data$time >= t1,]
  return(dim(temp)[1])
}
N = dim(data)[1]
ni = function(i){
  id = which(X == Xd[i])
  return(length(X) - id + 1)
}
ci = function(i){
  xi = Xd[i]
  xi1 = Xd[i + 1]
  temp = data[data$time > xi & data$time< xi1,] ## < or <=?
  return(sum(temp$status == 0))
}

# slud's method
part2_version1 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      part3 = ni(i) - 1 + rou(Xd[i])
      if(part3 == 0){
        part3 = 10e-10
      }
      temp2 = temp2 * (ni(i) - 1)/(part3)
    }
    temp = temp + ci(k) * temp2
  }
  return(temp /N)
}

# correct slud method 1
part2_version2 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      part3 = ni(i)
      if(part3 == 0){
        part3 = 10e-10
      }
      temp2 = temp2 * (1 - rou(Xd[i])/part3)
    }
    temp = temp + ci(k) * temp2
  }
  return(temp /N)
}

# correct slud method 2
part2_version3 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      part3 = ni(i)
      if(part3 == 0){
        part3 = 10e-10
      }
      temp2 = temp2 * (1 - rou(Xd[i])/part3)
    }
    temp = temp + ci(k) * temp2
  }
  i = dt
  part3 = ni(i)
  if(part3 == 0){
    part3 = 10e-10
  }
  finals = (1 - rou(Xd[i])/part3)
  temp = temp / finals
  return(temp /N)
}

# calculate the S(t)
Spt = function(t){
  nt = sum(data$time > t)
  part1 = 1/N * nt 
  
  s1 = part1 + part2_version1(t)
  s2 = part1 + part2_version2(t)
  s3 = part1 + part2_version3(t)
  
  return(list(s1 = s1, s2 = s2, s3 = s3))
}

# the effects of three methods
s1 = c(); s2 = c(); s3 = c(); s0 = c()
for(t in data$time){
  res = Spt(t)
  s0 = c(s0, S(t))
  s1 = c(s1, res$s1)
  s2 = c(s2, res$s2)
  s3 = c(s3, res$s3)
}

mean(abs(s0 - s1))
mean(abs(s0 - s2))
mean(abs(s0 - s3))

# km
fit1 = survfit(Surv(time, status) ~ 1, data=data)
fit2 = km.ci(fit1)

# draw the plot
plot(data$time, s0, type ='l',cex = 2, xlab = 'time', ylab = 'S(t)', main = 'Example 1')
lines(data$time, s1, lty = 2, col = 2, cex = 2)
lines(data$time, s2, lty = 5, col = 3, cex = 2)
lines(data$time, s3, lty = 4, col = 4, cex = 2)
lines(fit1$time, fit1$surv, col = 6, cex = 2)
lines(fit2$time[1:79], fit2$upper[1:79], col = 6, cex = 1, lty = 2)
lines(fit2$time[1:79], fit2$lower[1:79], col = 6, cex = 1, lty = 2)
legend('topright', legend = c('True S(t)','Slud','change1','change2','KM'),
       col = c(1,2,3,4,6),
       lty = c(1,2,5,4,1), cex = 0.5)

########################################################################################

##### Example 2
## piecewise

# functions
f_ts1 = function(t,s){
  return(exp(-s-t))
}
# if t>s
f_ts2 = function(t,s){
  return(10 * exp(8*s - 10*t))
}
# f(t) 
f_t = function(t){
  return(9/4 * exp(-2 * t) - 5/4 * exp(-10 * t))
}
# S(t)
S_t = function(t){
  return(9/8 * exp(-2 * t) - 1/8 * exp(-10 * t))
}
# phi(t)
phi_t = function(t){
  return(exp(-2 * t))
}
# Sx(t)
Sxt = function(t){
  return(exp(-2 * t))
}
rho = function(t){
  return((f_t(t)/phi_t(t) - 1)/(S_t(t)/Sxt(t) -1))
}

rho(1)
rho(2)
rho(4)

# generate data
set.seed(123)  
Ss = rep(seq(0,5,0.0001), each = 100)
Tt = rep(seq(0,5,0.0001), 100)
P1 = f_ts1(Tt, Ss)
P2 = f_ts2(Tt, Ss)
grid_data = data.frame(subj = 1:length(P1), s = Ss, t = Tt, p1 = P1, p2 = P2) 
its = grid_data$t > grid_data$s
p = ifelse(its, P2, P1)
grid_data$p = p
grid_data$p = grid_data$p/sum(grid_data$p)

N = 100
sample_data = sample(1:length(grid_data$p), size = N, prob = grid_data$p)

# sampled data 
data = grid_data[sample_data,] 
data = data.frame(deathtime = data$s, censortime = data$t, status = (data$s< data$t))
data$time = ifelse(data$status == 1, data$deathtime, data$censortime)
data$status = ifelse(data$status == TRUE, 1, 0)
data = round(data,4)
length(unique(data$time))
dim(data)
rownames(data) = NULL

# remove duplicated
time_du = round(as.numeric(names(which(table(data$time)>1))),3)
unique_time = unique(data$time)
data_temp = c()
for(i in 1:length(unique_time)){
  temp = data[data$time == unique_time[i],][1,]
  data_temp = rbind(data_temp, temp)
}
data = data_temp
dim(data)
sum(table(data$time)>1)

# true deathtime data
data0 = data
data0$status = 1
data0$time = data0$deathtime
head(data)
dim(data)

# get death time
X = sort(data$time)
data = data[order(data$time),]
d = sum(data$status == 1)
data_death = data[data$status == 1, ]; rownames(data_death) = NULL
Xd = data_death$time
length(Xd)
true_rou_values = rho(Xd) # the true rho values 
rownames(data) = NULL

# distributions for the scenario:
# if t<=s

##########################################################
# functions for estimation 

ni = function(i){
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
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      xd = Xd[i]
      if(Xd[i] == 0){xd = 10e-10}
      part3 = ni(i) - 1 + rho(xd)
      if(part3 == 0){
        part3 = 10e-10
      }
      temp2 = temp2 * (ni(i) - 1)/(part3)
    }
    temp = temp + ci(k) * temp2
  }
  return(temp /N)
}

part2_version2 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      part3 = ni(i)
      if(part3 == 0){
        part3 = 10e-10
      }
      xd = Xd[i]
      if(Xd[i] == 0){xd = 10e-10}
      temp2 = temp2 * (1 - rho(xd)/part3)
    }
    temp = temp + ci(k) * temp2
  }
  return(temp /N)
}

part2_version3 = function(t){
  N = dim(data)[1]
  dt = sum(data$time <= t & data$status == 1)
  nt = sum(data$time > t)
  temp = 0
  for(k in 0:(dt - 1)){
    temp2 = 1
    for(i in (1+k):dt){
      part3 = ni(i)
      if(part3 == 0){
        part3 = 10e-10
      }
      xd = Xd[i]
      if(Xd[i] == 0){xd = 10e-10}
      temp2 = temp2 * (1 - rho(xd)/part3)
    }
    temp = temp + ci(k) * temp2
  }
  
  i = dt
  part3 = ni(i)
  if(part3 == 0){
    part3 = 10e-10
  }
  
  xd = Xd[i]
  if(Xd[i] == 0){xd = 10e-10}
  
  finals = (1 - rho(xd)/part3)
  
  temp = temp / finals
  
  return(temp /N)
}

Spt = function(t){
  nt = sum(data$time > t)
  part1 = 1/N * nt 
  
  s1 = part1 + part2_version1(t)
  s2 = part1 + part2_version2(t)
  s3 = part1 + part2_version3(t)
  
  return(list(s1 = s1, s2 = s2, s3 = s3))
}

# results
s1 = c(); s2 = c(); s3 = c(); s0 = c()
for(t in data$time){
  res = Spt(t)
  s0 = c(s0, S_t(t))
  s1 = c(s1, res$s1)
  s2 = c(s2, res$s2)
  s3 = c(s3, res$s3)
}

mean(abs(s0 - s1))
mean(abs(s0 - s2))
mean(abs(s0 - s3))


fit1 = survfit(Surv(time, status) ~ 1, data=data)
fit2 = km.ci(fit1)

plot(data$time, s0, type ='l',cex = 2, xlab = 'time', ylab = 'S(t)', main = 'Example 2')
lines(data$time, s1, lty = 2, col = 2, cex = 2)
lines(data$time, s2, lty = 5, col = 3, cex = 2)
lines(data$time, s3, lty = 4, col = 4, cex = 2)
lines(fit1$time, fit1$surv, col = 6, cex = 2)
lines(fit2$time[1:94], fit2$upper[1:94], col = 6, cex = 1, lty = 2)
lines(fit2$time[1:94], fit2$lower[1:94], col = 6, cex = 1, lty = 2)
legend('topright', legend = c('True S(t)','Slud','change1','change2'),
       col = c(1,2,3,4),
       lty = c(1,2,5,4), cex = 0.5)
