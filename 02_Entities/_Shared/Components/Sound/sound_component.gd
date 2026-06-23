# Base des composants sonores d'une entité. Comme AnimationComponent, c'est un
# traducteur : il écoute les évènements de l'entité et déclenche les sons
# correspondants via AudioManager. Sous-classer pour définir quels sons jouer.

class_name SoundComponent
extends EntityComponent
