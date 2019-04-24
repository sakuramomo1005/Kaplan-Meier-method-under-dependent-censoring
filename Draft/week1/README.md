### Paper searching

* Title: *Censoring issues in survival analysis* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/CENSORING%20ISSUES%20IN%20SURVIVAL%20ANALYSIS.pdf)
   * Old review of censor, 1997
   * Mentioned other papers: (feel maybe useful but not available)
      * *Bounds on net survival probabilities for dependent competing risks* (not available)
      * *Presenting censored survival data when censoring and survival times may not be independent* (not available)
      * *Dependent competing risks and summary survival curves* (Eric V. Slud's paper) [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/Dependent%20competing%20risks%20and%20summary%20survival%20curves.pdf)
   
##### 1. Whether there is bias when the censoring is informative?

For the below papers, there is bias when the censor C is dependent on T. And usually the estimated bias from Kaplan Meier method cannot be ignored. 


*  Title: *Impact of Informative Censoring on the Kaplan-Meier Estimate of Progression-Free Survival in Phase II Clinical Trials*
[paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/Impact%20of%20Informative%20Censoring%20on%20the%20Kaplan-Meier%20Estimate%20of%20Progression-Free%20Survival%20in%20Phase%20II%20Clinical%20Trials.pdf)
   *  2014
   *  A simulation study
   *  Brief conclusion: 
The simulations show that the magnitude of the bias depends primar- ily on the proportion of patients who are informatively censored and secondarily on the hazard ratio between those who are informatively censored and those who remain on study.

* Title: *Nonparametric estimation of successive duration times under dependent censoring* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/Nonparametric%20estimation%20of%20successive%20duration%20times%20under%20dependent%20censoring.pdf)
   * 1998
   * Focused on two duriation times, like HIV first and then AIDs. The two times are correlated and not independent.
   * The paper shows that even when the two times have week correlation, the bias from Kaplan Meier is large.
   
* Title: *Estimating marginal survival function by adjusting for dependent censoring using many covariates* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/ESTIMATING%20MARGINAL%20SURVIVAL%20FUNCTION%20BY%20ADJUSTING%20FOR%20DEPENDENT%20CENSORING%20USING%20MANY%20COVARIATES.pdf)
   * 2004
   * Marginal model, kernal function
   * In their results (table1 and table2) Kaplan-Meier can have large bias, when the T and C are dependent through covariates L 

##### 2. Alternative method?

* Title: *A Model for Informative Censoring* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/A%20Model%20for%20Informative%20Censoring.pdf)
   * 1989
   * Introduce a new method: modified Kaplan-Meier estimator (MKME).
   * An additional assumption: censoring only happens in high risk subpopulation.  
   * It mentioned that: "Williams and Lagakos (1977) and Lagakos and Williams (1978) defined a "cone-class" of censoring models that are indexed by a parameter  <a href="https://www.codecogs.com/eqnedit.php?latex=\theta&space;\in&space;[0,1]]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\theta&space;\in&space;[0,1]]" title="\theta \in [0,1]]" /></a>
. When <a href="https://www.codecogs.com/eqnedit.php?latex=$\theta&space;=&space;0$" target="_blank"><img src="https://latex.codecogs.com/gif.latex?$\theta&space;=&space;0$" title="$\theta = 0$" /></a> , censoring immediately precedes death; H_{hat} is the appropriate estimator of S(·). When $\theta$ = 1, the KME is the appropriate estimator."
   
  
* Title: *Correcting for dependent censoring
in routine outcome monitoring data by applying the inverse probability censoring weighted estimator* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/Correcting%20for%20dependent%20censoring%20in%20routine%20outcome%20monitoring%20data%20by%20applying%20the%20inverse%20probability%20censoring%20weighted%20estimator.pdf)
   * 2016
   * Weight method: inverse probability censoring weighted estimator (IPCW)
   * How the weight calculated?
     * times the inverse of weight in denominator and nominator
     * the weight K(t) is caluclated similar as S(t), by just replacing the death time T with censor time C
   
* Title: *The Kaplan–Meier Estimator as an Inverse- Probability-of-Censoring Weighted Average* [paper link](https://github.com/sakuramomo1005/Kaplan-Meier-method-under-dependent-censoring/blob/master/Draft/week1/papers/The%20Kaplan%E2%80%93Meier%20Estimator%20as%20an%20InverseProbability-of-Censoring%20Weighted%20Average.pdf)
   * 2012
   * IPCW method
   
