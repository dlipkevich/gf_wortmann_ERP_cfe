﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДатаОстатков = ТекущаяДата();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Печать(Команда)
	
	ПараметрыПечати = Новый Структура("ДатаОстатков");
	
	ЗаполнитьЗначенияСвойств(ПараметрыПечати, ЭтотОбъект);
	
	Закрыть(ПараметрыПечати);
	
КонецПроцедуры

#КонецОбласти

