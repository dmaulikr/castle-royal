//
//  GameScene.swift
//  castle royal
//
//  Created by Antoine FeuFeu on 15/07/2016.
//  Copyright (c) 2016 Antoine FeuFeu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let AudioNodeGeneral = SKNode()
    let AnimationNodeGenerel = SKNode()

    let IlotNode = SKNode()
    
    // pierres :
    var boite_a_pierre = [pierre]()
    var selectionCarte = selection()
    let selectionSprite = SKSpriteNode(texture: textures.pierre_select, color: UIColor.clearColor(), size: CGSize(width: information.ScreenWidth/6, height: information.ScreenWidth/6))
    let selectionSpriteIlot = SKSpriteNode(texture: textures.zone_select)
    var heroPosable: heroSprite? = nil
    
    var victoireVar = false
    let bati: batiment? = batiment(imageNamed: "cristal_allier")
    let bat: batiment? = batiment(imageNamed: "cristal_enemie")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        
        collectionHero.removeAll()
        
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.addChild(AudioNodeGeneral)
        self.addChild(AnimationNodeGenerel)
        information = InformationGeneral(frame: self.frame, audioNode: self.AudioNodeGeneral, animationNode: self.AnimationNodeGenerel)
        information.solHeight = textures.zone.size().height
        information.solwidth = textures.zone.size().width
        self.addChild(IlotNode)
        self.addChild(selectionSprite)
        self.selectionSprite.hidden = true
        self.selectionSprite.zPosition = 998
        self.addChild(selectionSpriteIlot)
        self.selectionSpriteIlot.hidden = true
        self.selectionSpriteIlot.zPosition = 42
        // demarrer positionement et init des ilots/infoilots
        var colonne: CGFloat = 1.0
        var ranger: CGFloat = 0.0
        for i in 1...35 {
            
            let sprite = ilot(texture: textures.zone) // colonne et ranger de l'ilot utiliser dans touch
            sprite.colonne = colonne
            sprite.zPosition = 40 - CGFloat(i)
            ranger += 1
            sprite.ranger = ranger
            if ranger > 5 {
                ranger = 1
                colonne += 1
            }
            sprite.position = CGPoint(x: self.frame.origin.x + (ranger*sprite.size.width) - 32.5, y: self.frame.origin.y + 100 + (colonne*109.0))
            
            let info = ilotInfo(colonne: colonne, ranger: ranger, ilotReferance: sprite) // utilisez pour les heros, batiments ...
            sprite.ide = key(colonne, ranger: ranger)
            collectionIlot[sprite.ide] = info
            collectionIlot[sprite.ide]?.contient = ilotContient.vide
            IlotNode.addChild(sprite)
            
            if i == 1 || i == 2 || i == 3 || i == 4 || i == 5 { // zone de deploiment allier
               sprite.texture = textures.zone_deplacement
               collectionIlot[sprite.ide]?.contient = ilotContient.deploiementAllier
            }
            if i == 31 || i == 32 || i == 33 || i == 34 || i == 35 { // <-- enemie
                sprite.texture = textures.zone_deplacement
                collectionIlot[sprite.ide]?.contient = ilotContient.deploiementEnemie
            }
            
            if i == 23 {
               
               bat!.position = CGPointMake(0, 55)
               bat!.size = CGSize(width: sprite.size.width*0.7, height: sprite.size.width*0.7)
               sprite.addChild(bat!)
               bat!.zPosition = sprite.zPosition + 1
               bat!.ide = sprite.ide
               collectionIlot[sprite.ide]?.contient = ilotContient.batimentEnemie
               collectionIlot[sprite.ide]!.building = bat
               bat!.parametrerLabel()
               
                let particule = SKEmitterNode(fileNamed: "cristal_Doree.sks")
                bat!.addChild(particule!)
                particule?.targetNode = self
                
                
            }
            if i == 13 {
                
                bati!.position = CGPointMake(0, 55)
                bati!.size = CGSize(width: sprite.size.width*0.7, height: sprite.size.width*0.7)
                sprite.addChild(bati!)
                bati!.zPosition = sprite.zPosition + 1
                bati!.ide = sprite.ide
                collectionIlot[sprite.ide]?.contient = ilotContient.batimentAllier
                collectionIlot[sprite.ide]!.building = bati
                bati!.parametrerLabel()
                bati!.type = ilotContient.batimentEnemie
                let particule = SKEmitterNode(fileNamed: "cristal_Bleu.sks")
                bati!.addChild(particule!)
                particule?.targetNode = self


            }
            
            
        }
        // fin ilot 
        // pierre 
        INITpierre()
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(1),
            SKAction.runBlock({
                self.tour()
                
            })
            ])))
        information.AnimationNode?.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(4, withRange: 3),
            SKAction.runBlock({
                let nunu = SKSpriteNode(texture: textures.nuage)
                nunu.position = CGPoint(x: self.frame.width + textures.nuage.size().width, y: CGFloat.random(self.frame.height))
                nunu.zPosition = -1
                nunu.size = CGSize(width: CGFloat.random(min: 500, max: 700), height: CGFloat.random(min: 80, max: 160))
                self.addChild(nunu)
                nunu.runAction(SKAction.sequence([
                    SKAction.moveTo(CGPoint(x: self.frame.origin.x - textures.nuage.size().width, y: nunu.position.y), duration: 20),
                    SKAction.waitForDuration(6),
                    SKAction.removeFromParent()
                    ]))
            })
            ])))
        
        
    }
    
    func rangerAleatoire() -> CGFloat {
        return CGFloat(arc4random_uniform(5) + 1)
    }
    
       
    func popEnemie(type: hero, colonne: CGFloat, ranger: CGFloat) { // restriction case deploiement !
        
        if let ilot = collectionIlot[key(colonne, ranger: ranger)] {
            
            if ilot.contient == ilotContient.deploiementEnemie && ilot.hero == nil {
                var heroe: heroSprite!
                switch type {
                case hero.mage:
                    heroe = mageSpirituel()
                case hero.demoniste:
                    heroe = demoniste()
                case hero.moltanica:
                    heroe = moltanica()
                case hero.vlad:
                    heroe = vladDracula()
                case hero.roiFantome:
                    heroe = roiFantome()
                case hero.grimfield:
                    heroe = grimfield()
                case hero.harpie:
                    heroe = Harpie()
                case hero.sirenia:
                    heroe = sirenia()
                default:
                    fatalError("attention aucune carte n'est posable -> selectioncarte.pier.contienthero = nul ou le hero n'est pas specifier")
                }
                heroe.allier = false
                heroe.initHalo()
                heroe.position = CGPoint(x: ilot.position.x, y: ilot.position.y + 150)
                heroe.name = "hero"
                heroe.info = heroInfo(colonne: colonne, ranger: ranger)
                self.addChild(heroe)
                collectionHero[heroe.action] = heroe
            }
            
        }
    }
    
    func tour() {
        
        self.enumerateChildNodesWithName("hero", usingBlock: { (superHero, _) in
            
            if superHero is heroSprite {
                let Hero = superHero as! heroSprite
                Hero.reflexion()
            }
            
        })
    }
    
    func randomCarte() -> hero {
        let a = Int(arc4random_uniform(8) + 1) // n pour s'assurer de ne pas tomber sur ce qui n'est pas encore integrer
        switch a {
        case 1:
            return hero.mage
        case 2:
            return hero.demoniste
        case 3:
            return hero.moltanica
        case 4:
            return hero.vlad
        case 5:
            return hero.roiFantome
        case 6:
            return hero.grimfield
        case 7:
            return hero.harpie
        case 8:
            return hero.sirenia
        default:
            return hero.mage
        }
    }

    
    func INITpierre() {
        
        
        for i in 1...5 {
            
            let pier = pierre(carte: hero.grimfield, numero: i)
            let info = collectionIlot[key(1, ranger: CGFloat(i))]
            pier.position = CGPoint(x: (info?.ilotReferance.position.x)!, y: (info?.ilotReferance.position.y)! - 130)
            self.addChild(pier)
            self.boite_a_pierre.append(pier)
        }
        
        
    }

    func key(colonne: CGFloat, ranger: CGFloat) -> CGFloat {
        return colonne*10 + ranger
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            for pier in boite_a_pierre {
                
                if pier.containsPoint(location) {
                    
                    selectionCarte.heroVisible = false 
                    
                    if selectionCarte.select == true && selectionCarte.pier.numero == pier.numero {
                        
                        pier.runAction(SKAction.playSoundFileNamed("select_ok.mp3", waitForCompletion: false))
                        selectionCarte.pier = pier 
                        selectionSprite.position = pier.position
                        selectionSprite.hidden = true
                        selectionCarte.select = false
                        
                    } else if selectionCarte.select == true && selectionCarte.pier.numero != pier.numero  {
                        
                        pier.runAction(SKAction.playSoundFileNamed("select.caf", waitForCompletion: false))
                        selectionCarte.pier = pier
                        selectionSprite.position = pier.position
                        selectionSprite.hidden = false
                        
                    } else if selectionCarte.select == false {
                        pier.runAction(SKAction.playSoundFileNamed("select.caf", waitForCompletion: false))
                        selectionCarte.select = true
                        selectionCarte.pier = pier
                        selectionSprite.position = pier.position
                        selectionSprite.hidden = false
                    }
                   
                   
                } 
                
            }
            
        }
    } // touch began 
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if selectionCarte.select {
                
                
                for child in IlotNode.children {
                    
                    if child.containsPoint(CGPoint(x: location.x, y: location.y - 75)) {
                        
                        let ile = child as! ilot
                        
                       self.selectionSpriteIlot.position = child.position
                       self.selectionSpriteIlot.hidden = false
                       
                        
                        if heroPosable == nil && selectionCarte.pier.carte != nil {
                        
                            
                            switch selectionCarte.pier.contientHero! {
                            case hero.mage:
                                heroPosable = mageSpirituel()
                            case hero.demoniste:
                                heroPosable = demoniste()
                            case hero.moltanica:
                                heroPosable = moltanica()
                            case hero.vlad:
                                heroPosable = vladDracula()
                            case hero.roiFantome:
                                heroPosable = roiFantome()
                            case hero.grimfield:
                                heroPosable = grimfield()
                            case hero.harpie:
                                heroPosable = Harpie()
                            case hero.sirenia:
                                heroPosable = sirenia()
                            default:
                                fatalError("attention aucune carte n'est posable -> selectioncarte.pier.contienthero = nul ou le hero n'est pas specifier")
                            }
                            self.addChild(heroPosable!)
                            
                           heroPosable!.info = heroInfo(colonne: ile.colonne, ranger: ile.ranger)
                           heroPosable?.position = CGPoint(x: ile.position.x, y: ile.position.y + 75)
                           
                           selectionCarte.ide = ile.ide 
                           selectionSpriteIlot.blendMode = SKBlendMode.Alpha
                           selectionCarte.ok = true
                            
                        } else if collectionIlot[ile.ide]?.contient == ilotContient.deploiementAllier && collectionIlot[ile.ide]!.hero == nil {
                            heroPosable?.position = CGPoint(x: ile.position.x, y: ile.position.y + 75)
                            heroPosable?.info = heroInfo(colonne: ile.colonne, ranger: ile.ranger)
                            selectionSpriteIlot.blendMode = SKBlendMode.Alpha
                            selectionCarte.ok = true
                            
                            
                        } else {
                            selectionSpriteIlot.blendMode = SKBlendMode.Subtract
                            heroPosable?.position = CGPoint(x: ile.position.x, y: ile.position.y + 75)
                            selectionCarte.ok = false
                        }
                        selectionCarte.heroVisible = true
                        
                    }
                    
                }
                
                
            }
            
        }
    } //
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectionSpriteIlot.hidden = true
        
        if selectionCarte.select == true && selectionCarte.heroVisible == true && selectionCarte.ok == true {
            
            if let copy = heroPosable {
               
               self.heroPosable?.removeFromParent()
               self.heroPosable = nil
               copy.name = "hero"
               collectionHero[copy.action] = copy
               copy.initHalo()
               self.addChild(copy)
               selectionCarte.select = false
               selectionSprite.hidden = true
                
                let number = selectionCarte.pier.numero
               
               
                
               self.selectionCarte.pier.carte?.runAction(SKAction.sequence([
                SKAction.fadeAlphaTo(0.0, duration: 1),
                SKAction.waitForDuration(1),
                SKAction.removeFromParent()
                ]))
                self.ProchaineCarte(self.randomCarte(), pier: selectionCarte.pier)
                self.popEnemie(self.randomCarte(), colonne: 7, ranger: self.rangerAleatoire())
                
                for pier in boite_a_pierre {
                    if pier.numero == number {
                       pier.carte = nil
                    }
                }
                
                
            }
            
        } else if selectionCarte.ok == false {
            
            heroPosable?.removeFromParent()
            heroPosable = nil
            selectionCarte.select = false
            selectionSprite.hidden = true
            
        }
        
    }
    
    func ProchaineCarte(carteType: hero, pier: pierre) {
     
        var carte: SKSpriteNode!
        switch carteType {
        case .demoniste:
            carte = SKSpriteNode(texture: textures.carteDemoniste)
        case .duc:
            carte = SKSpriteNode(texture: textures.carteDuc)
        case .mage:
            carte = SKSpriteNode(texture: textures.carteMage)
        case .moltanica:
            carte = SKSpriteNode(texture: textures.carteMoltanica)
        case .vlad:
            carte = SKSpriteNode(texture: textures.carteVlad)
        case .roiFantome:
            carte = SKSpriteNode(texture: textures.carteRoiFantome)
        case .grimfield:
            carte = SKSpriteNode(texture: textures.carteGrimfield)
        case .sirenia:
            carte = SKSpriteNode(texture: textures.carteSirenia)
        case .harpie:
            carte = SKSpriteNode(texture: textures.carteReineHarpie)
        }
        carte.setScale(0.0)
        carte.zPosition = pier.zPosition + 2
        pier.addChild(carte)
        pier.contientHero = carteType
        carte.runAction(
            SKAction.sequence([
            SKAction.waitForDuration(0.8),
            SKAction.scaleTo(1.0, duration: 0.8),
                SKAction.runBlock({
                    pier.carte = carte
                    self.runAction(SKAction.playSoundFileNamed("pioche.mp3", waitForCompletion: false))
                })
                
                ]))
        
        
    }
    
    override func didFinishUpdate() {
    
        if MatchTerminer {
            
            victoireVar = MatchGagnant == 1 ? true : false
            self.victoire()
            MatchTerminer = false
        }
    
    }
    
    
    func victoire() {
        self.removeAllActions()
        
        
        
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(2),
            SKAction.runBlock({
                
                let label = SKLabelNode(fontNamed: "SegoePrint-Bold")
                label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                label.fontColor = UIColor.orangeColor()
                label.setScale(0.0)
                label.fontSize = 120
                self.addChild(label)
                label.zPosition = 500
                label.runAction(SKAction.scaleTo(1.0, duration: 0.7))
                
                if !self.victoireVar {
                    self.runAction(SKAction.playSoundFileNamed("Battle_Lose.mp3", waitForCompletion: false))
                    label.text = "DEFAITE !"
                    label.fontColor = UIColor.redColor()
                } else {
                    self.runAction(SKAction.playSoundFileNamed("Battle_Win.mp3", waitForCompletion: false))
                    label.text = "VICTOIRE !"
                }
            }), SKAction.waitForDuration(2),
            SKAction.runBlock({
                let sceneS = GameScene(size: self.frame.size)
                let transition = SKTransition.fadeWithColor(self.victoireVar ? UIColor.greenColor() : UIColor.redColor(), duration: 3)
                self.view?.presentScene(sceneS, transition: transition)

            })
            ]))
        
        
    }
    
}


















