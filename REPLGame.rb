$archetypes = { warrior: {ws: 45, bs: 30, s:40, t:40, a: 30, i: 25, p: 30, wp: 30, fel: 35}, crusader: {ws: 40, bs: 30, s: 35, t: 45, a: 35, i: 30, p: 30, wp: 40, fel: 25},
                          sorcerer: {ws: 25, bs: 25, s:30, t:35, a: 40, i: 50, p: 35, wp: 50, fel: 20}, ranger: {ws: 25, bs: 45, s: 30, t: 40, a: 45, i: 30, p: 40, wp: 30, fel: 30} }

$monsterStats = {harpy: {ws: 30, bs: 0, s: 20, t: 20, a: 45, i: 10, p: 40, wp: 35, fel: 20}}

$d10 = (1..10).to_a
$d100 = (1..100).to_a



class CombatAction
  attr_accessor :name, :description
  def initialize
    @name = ""
    @description = ""
  end

  def action character
  end
end

class StandartAttack < CombatAction
  @name = "Standard attack"
  @description = "An attack based on weapon skill if a melee weapon is being used, or ballistic skill if a ranged weapon is being used."
  attackDamage = 0
  
  def action attacker
    if attacker.weapon.ranged == false
      if rolld100 <= attacker.stats[:ws]
          attackDamage = attacker.weapon.damage attacker
        else
          puts "#{attacker.name} missed the attack"; 0
      end
    else
      if rolld100 <= attacker.stats[:bs]
          attackDamage = attacker.weapon.damage attacker
        else
          puts "#{attacker.name} missed the attack"; 0
      end
    end
  end
end


$StAttack = StandartAttack.new

class Character
  attr_accessor :name, :stats, :inventory, :weapon, :status, :health, :experience, :lvlUp, :alignment, :initiative, :playerCharacter, :weapon
  def initialize(name, archetype)
    @name = name
    @stats = $archetypes[archetype]
    @inventory = Hash.new
    @weapon = Fist.new
    @status = Hash.new
    @health = 10
    @experience = 0
    @lvlUp = 100
    @alignment = "good"
    @initiative = 0
    @playerCharacter = true
  end
end

def characterNaming
  puts "Name?"
  name = gets.to_s.chomp.downcase.capitalize
  if name.index(/[1234567890]/) == nil
    puts "Ok #{name}, this might seem weird, but I need you to
    mark on this list the answer to the following question, with which of these archetypes do you feel more identified?"
  else
    puts "A number in a name, hipsters these days.\nAnyways, this might seem weird, but I need you to mark on this list the answer to the following question.\nWith which of these archetypes do you feel more identified?"
  end
  name
end

def archetypeAssignment

  validChoice = false
  while validChoice == false
    puts "(W)arrior"; puts "(C)rusader"; puts "(S)orcerer"; puts "(R)anger"
    archetypeChoice = gets.chomp.downcase

    case archetypeChoice
      when "w" then puts "Hey who needs brains when you can punch your way through life am I right?";return :warrior
      when "c" then  puts "It's no longer the dark ages, but to each its own";return :crusader
      when "r" then puts "So killing them from afar, I bet you don't even look them to the eye, coward."; return :ranger
      when "s" then puts "Hey look at mr.Fancypants, shooting lighting from his fingertips and stuff."; return :sorcerer
      else puts "look, it's not that hard, try again"
    end
  end
end

def characterCreation
  name = characterNaming
  archetype = archetypeAssignment
  $character = Character.new(name, archetype)
end

class Monster
  attr_accessor :name, :stats, :health, :alignment, :initiative, :playerCharacter, :weapon
  def initialize
    @name = ""
    @stats = {}
    @health = 0
    @alignment = "evil"
    @playerCharacter = false
    @weapon = Fist.new
    @initiative = 0
  end
end

class Harpy < Monster
  def initialize
    super
    @name = "Harpy"
    @health = 7
    @stats = $monsterStats[:harpy]
    @weapon = Talons.new
  end
end

class Weapon
  attr_accessor :name, :description, :ranged
  def initialize
    @name = ""
    @description = ""
    @ranged = false
  end

  def damage
  end
end

class Sword < Weapon
  def initialize
    super
    @name = "Sword"
    @description = "Oddly this sword is made of silicon: damage = 1d10 + SB"
    @ranged = false
  end

  def damage character
    damage = rolld10 + (character.stats[:s] / 10).round
    puts "You swing your sword at the enemy doing #{damage} damage"
    damage
  end
end

class Fist < Weapon
  def initialize
    super
    @name = "Fist"
    @description = "Your good old knuckes: damage = 1d10"
  end

  def damage character
    damage = rolld10
    puts "You punch your enemy doing #{damage}"
    damage
  end
end

class Talons < Weapon
  def initialize
    super
    @name = "Talons"
    @description = "Murderous rending talons: damage = 1d10"
  end

  def damage character
    damage = rolld10 5
    puts "The talons rend flesh and sinew alike doing: #{damage} damage"
    damage
  end
end

#Global arrays that will hold both sides when it is time to fight
$goodArray = []
$badArray = []
#Glogal array to hold all characters
$combatants = []


#charToUse is an integer representing the index of the characteristic to be tested
def charRoll characterStats, charToUse
      if rolld100  <= characterStats[charToUse]
        true
      else
        false
      end
end

def rolld10
  $d10.shuffle.pop
end

def rolld100
  $d100.shuffle.pop
end

def chooseWeapon character
   validAnswer = false
  while validAnswer == false
    puts "Choose a weapon"
#    puts "(A)xe: 1d10 + 3 damage, -10 dodge"
    puts "(S)word: 1d10 damage"
#    puts "(B)ow: 1d10 damage"
#    puts "(S)taff: 1d10 damage"
    choice = gets.chomp.downcase
    case choice
#      when "a" then $character.weapon = "axe"; validAnswer = true
      when "s" then $character.weapon = Sword.new; validAnswer = true
#      when "b" then $character.weapon = "bow"; validAnswer = true
#      when "s" then $character.weapon = "staff"; validAnswer = true
      else puts "Invalid entry"
    end
  end
end



###################COMBAT METHODS START#########################

def turnOrder  characters
  #checking initiative
  turnOrder = Array.new
  characters.each do |character|
  turnOrder.push character
  end
  #Testing turn order.
  turnOrder.each do |character|
    character.initiative = rolld10 - (character.stats[:a] / 10).round
  end
  puts turnOrder
  turnOrder.sort_by! { |character| character.initiative }
  #testing order
end

def splitIntoGroups characters
  characters.each do |character|
   $goodArray << character if character.alignment == "good"
   $badArray << character if character.alignment == "evil"
  end
end

def nPCchallenge attacker
  if attacker.alignment == "evil"
    defender = $goodArray.shuffle.pop
  else
    defender = $badArray.shuffle.pop
  end#closing if else
end

def pCchallenge attacker
  index = 1
  puts "Choose enemy to attack"
  $badArray.each do |monster|
    puts "#{index} #{monster.name}:  #{monster.health}"
    index+=1
  end
  validChoice = false
  while validChoice == false
    choice = gets.chomp.to_i
    if(1..$badArray.count).include? choice
      defender = $badArray[choice-1]
      validChoice = true
    else
      puts "Not a valid choice"
    end
  end
end

def death corpse
  if corpse.alignment == "evil"
    $badArray.delete_if {|elementToDelete| elementToDelete.object_id == corpse.object_id }
  else
    $goodArray.delete_if {|elementToDelete| elementToDelete.object_id == corpse.object_id }
  end
end

def combatOver?
  if $badArray.empty? || $goodArray.empty?
    true
  else
    false
  end
end



=begin
def combat enemies
  combatants = Array.new
  enemy = enemies.sample
  combatants << enemy
  combatants << $character
  combatants = turnOrder combatants
  attack combatants
end
=end
##################COMBAT METHODS END#####################
##################Testing Death#########################

######################################################
def gameOver defender
  if defender.playerCharacter == false
    puts "Congrats you won!! This concludes our demo"
  else
    puts "Shame, you got killed. This condludes our demo"
  end
end

########LEVELS START#################

def firstChoice
  validAnswer = false
  while validAnswer == false
    puts "--------------------What do you do?---------------------"
    puts "(G)rab a weapon from the rack."
    puts "(W)hat's this place?"
    choice = gets.chomp.downcase
    case choice
      when "g" then puts "--You walk up to the weapons rack and see the not so ample selection of weapons.--"; validAnswer = true
      when "w" then puts "By now you may have noticed that you are mute in this realm.\nThe motion to make you all mute was approved so that you would not ask stupid questions. In this realm you can only speak when spoken to."
      else puts "not a valid option"
    end
  end
end

def secondChoice character
  validAnswer = false
  while validAnswer == false
    puts "--------------What do you do?-----------------"
    puts "(G)o to the harpy room"
    puts "(L)ook around"
    choice = gets.chomp.downcase
    case choice
      when "g" then puts "You make your way to the room where the harpies have made their foul nest."; validAnswer = true
      when "l"
        if charRoll character.stats, :p
          puts "Looking around you found a health potion."
          character.inventory.store(:healthPotion, 1)
          puts "You make your way to the room where the harpies have made their foul nest."; validAnswer = true
        else
          puts "You look around, but are unable to find anything"
          puts "You make your way to the room where the harpy have made their foul nest."; validAnswer = true
        end
      end
  end
end

def harpyLair
  monsters = Array.new(5) { Harpy.new }
  puts "The stench of harpy droppings is unbearable, however it is your duty to clear this room of their vile presence."
  validAnswer = false
  while monsters.empty? == false
    while validAnswer == false
      puts "--------------What do you do?----------------"
      puts "(S)cream 'Caw caw!!'"
      answer = gets.chomp.downcase
      case answer
        when "s" then puts "You start screaming like a rabid chicken, needless to say, it attracts the harpies"; combat monsters; validAnswer = true
        else puts "Not a valid choice"
      end
    end
  end
end

def gamestart
  puts "Wake up."; puts "You fell asleep in line and I don' have all day so lets make this quick."
  $character = characterCreation
  puts $character.stats
  puts "Ok, that is all that I need for now, so a brief rundown. You are dead.\nBut don't feel bad everyone else is dead as well!\nHowever we are completely overcrowded and since it will take some time to clean up Earth, I have been assigned to give you some tasks to do around here.\nSo first thing you are going to do is pick a weapon from that rack over there, it's dangerous to go alone."
  firstChoice
#Choose weapon
  character = chooseWeapon character
#Second choice
  secondChoice $character
  harpyLair
end

#############LEVELS END###################

#gamestart
#--------------Testing

def pCchallengeTesting
  $badArray = Array.new(5) {Harpy.new}
  $character = characterCreation
  pCchallenge $character
end

def testingDeath
  harpy = Harpy.new
  $badArray << harpy
  puts $badArray[0].class
  death harpy
  puts $badArray[0].class
end

def testChallenge
  monsters = Array.new(5) { Harpy.new }
  goodMonsters = Array.new(5) { Harpy.new }
  
  goodMonsters.each do |goodHarpy|
    goodHarpy.alignment = "good"
    goodHarpy.name = "Good Harpy"
    $goodArray << goodHarpy
  end

  monsters.each {|monster| $badArray << monster }

  challenge monsters[0]
  challenge goodMonsters[0]
end

def testSideSplitting
  $character = characterCreation
  monsters = Array.new(5) { Harpy.new }

  monsters.each do |monster|
      $combatants << monster
    end

  $combatants << $character

  splitIntoGroups $combatants

  print $badArray
  puts ""
  print $goodArray
end


=begin
def attack combatants
  death = false
  while death == false
    attacker = combatants.shift
    if attacker.playerCharacter == false
      defender = combatants[0]
      damage = $StAttack.action attacker
      if damage > 0
         defender.health = defender.health - damage
          if defender.health <= 0
            death = true
            gameOver defender if defender.playerCharacter == true
          end
      end
      combatants << attacker
    else
      defender = combatants[0]
      validAnswer = false
      while  validAnswer == false
        puts "#{attacker.name}: #{attacker.health}"
        puts "#{defender.name}: #{defender.health}"
        puts "-----What do you do?-------"
        puts "(S)tandard Attack"
        choice = gets.chomp.downcase
        case choice
          when "s"
            validAnswer = true
            damage = $StAttack.action attacker
            combatants << attacker
            if damage > 0
              defender.health = defender.health - damage
              if defender.health <= 0
                death = true
                gameOver defender
                defender = nil
              end
            end
          else puts "Not a valid choice"
        end
      end
    end
  end
end
=end
#goes through each step of a combat, first by creating the enemy you will be fighting, which is just a sample monster from the monster array
#populates the combatants array with said monster and the character.
#the array is then passed to the turnOrder method in order to be organized
#the attack method is called.