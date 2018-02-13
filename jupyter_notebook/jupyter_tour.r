
head(iris)

hist(iris$Sepal.Length, main='demo plots!', col='salmon')

just_one_species = iris$Sepal.Length[iris$Species == 'setosa']
just_one_species

t.test(just_one_species, mu=10, alternative="less")

x = 1738

?plot
