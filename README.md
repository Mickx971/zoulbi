Le zoulbi-0.1 correspond à la réalisation du langage zoulbi version 0.1 qui inclue:
	- la sturcture de controle if-else
	- les boucles while et for
	- la reconnaissance du type chaîne de caractère
	- les affectations
	- le calcul d'expression arithmétique
	- l'évaluation d'expression booléenne
	- l'affichage des valeurs des variables

Notre parseur doit générer un arbre représentant l'ensemble des instructions d'un code source
avant l'exécution, ou évaluation de celui-ci.

Si nous finissons rapidement cette partie, nous essayerons de rajouter les fonctionnalités suivantes:
	- gestion des fonctions
	- gestion de la visibilité des variables
	- gestion des fonctions récursives

Ces éventuels ajouts de fonctionnalités se feront dans le répertoire zoulbi-0.2 



Exemple de programme zoulbi avec les fonctionnalités supplémentaires:

############

real fact(real n)
	if(n < 1)
		return 1
	end
	real f = 1
	while(n > 1)
		f = f * n
	end
	return f
end

void main()
	real n = 3
	bool b = n > 0
	real fact
	
	if(b == false)
		print("n est négatif")
	else
		fact = fact(n)
	end

	string s = "factoriel(n) vaut " + fact
	print(s)
end	

##############	
	
Il gère trois types: real, bool et str. 
Tous les blocs se finissent par le mot clé "end".
Il n'y a qu'une instruction par ligne et pas de point virgule en fin d'instruction.

 
