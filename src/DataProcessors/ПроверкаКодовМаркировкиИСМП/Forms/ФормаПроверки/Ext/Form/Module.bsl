﻿
&НаКлиенте
Процедура гф_ОбработкаОповещенияПосле(ИмяСобытия, Параметр, Источник)
	// #wortmann {
	// 1.1 Регистрация возвратов
	// Галфинд Sakovich 2022/11/17
	Если ИмяСобытия = "гф_ЗаявкаНаВозвратПроверкаКМ" 
		И ВладелецФормы = Источник Тогда
		Штрихкоды = Параметр;
		Подключаемый_ПолученыДанныеИзТСД(Штрихкоды);
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры
