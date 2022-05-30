//
//  ActionManager.swift
//  weatherBot
//
//  Created by Enrico Piovesan on 2017-09-09.
//  Copyright © 2017 Enrico Piovesan. All rights reserved.
//

import UIKit
import PromiseKit

class Action {
    
    var intent : Intent
    
    init(_ intent: Intent) {
        self.intent = intent
    }
    
    // MARK:- Update Message content
    func updateMessage() -> Promise<Message> {
        return Promise{ seal in
            switch intent.intentType {
            case .smalltalkGreetingsHello:
                smalltalkGreetingsHello().done { message in
                    seal.fulfill(message)
                }
            case .weather:
                weatherAction().done { message in
                    seal.fulfill(message)
                }.catch { (error) in
                    seal.reject(error)
                }
            case .weatherCondition:
                weatherConditionAction().done { message in
                    seal.fulfill(message)
                    }.catch { (error) in
                        seal.reject(error)
                }
            case .unKnow:
                unkowAction().done { message in
                    seal.fulfill(message)
                }.catch { (error) in
                    seal.reject(error)
            }
            }
        }
        
    }
    
    // MARK:- create a weather action
    func weatherAction() -> Promise<Message>  {
        let weatherMessageManager = WeatherMessageManager(weatherParameters: self.intent.parameters ?? nil)
        return Promise{ seal in
            firstly{
                weatherMessageManager.getLocation()
                }.then { (coordinates) -> Promise<Weather> in
                    WeatherService(WeatherRequest(coordinates: coordinates)).getWeather()
                }.done {(weather) in
                    seal.fulfill(Message(weather: weather))
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
    
    
    // MARK:- create a weather Condition action
    func weatherConditionAction() -> Promise<Message>  {
        let weatherMessageManager = WeatherMessageManager(weatherParameters: self.intent.parameters ?? nil)
        return Promise<Message>{ seal in
            firstly{
                weatherMessageManager.getLocation()
                }.then { (coordinates) -> Promise<Weather> in
                    WeatherService(WeatherRequest(coordinates: coordinates)).getWeather()
                }.done {(weather) in
                    seal.fulfill(Message(weather: weather, intent: self.intent))
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
    
    // MARK:- create an unkow action
    func smalltalkGreetingsHello() -> Promise<Message> {
        let textMessage = intent.speech != "" ? intent.speech : "Hello!"
        let message = Message(text: textMessage!, date: Date(), type: .botText)
        return Promise{ seal in
            seal.fulfill(message)
        }
    }
    
    // MARK:- create an unkow action
    func unkowAction() -> Promise<Message> {
        let textMessage = intent.speech != "" ? intent.speech : "I'm not sure I understand what you are saying, but I am learning more every day."
        let message = Message(text: textMessage!, date: Date(), type: .botText)
        return Promise{ seal in
            seal.fulfill(message)
        }
    }
    
}
