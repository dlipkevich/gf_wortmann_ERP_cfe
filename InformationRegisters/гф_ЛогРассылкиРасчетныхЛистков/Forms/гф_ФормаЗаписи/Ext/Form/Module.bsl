﻿#Область ОбработчикиСобытийФормы
	
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		
		ЭтотОбъект.ТолькоПросмотр = Истина;
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти
