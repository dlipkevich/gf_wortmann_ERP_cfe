﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	// #wortmann {Галфинд Sakovich 2022/09/20
	Список.ТекстЗапроса = СтрЗаменить(Список.ТекстЗапроса, 
		"ВЫБРАТЬ
		|", 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|");	
	// } #wortmann

КонецПроцедуры

#КонецОбласти