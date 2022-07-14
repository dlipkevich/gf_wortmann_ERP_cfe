﻿
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)

	Если Параметры.Свойство("ДляСпецификации") Тогда
		
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		
		ЭлементОтбора.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("Организация");
		ЭлементОтбора.ВидСравнения		= ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.Использование		= Истина;
		ЭлементОтбора.ПравоеЗначение	= Параметры.Отбор.Организация;
		ЭлементОтбора.РежимОтображения	= РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
	
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		
		ЭлементОтбора.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("Партнер");
		ЭлементОтбора.ВидСравнения		= ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.Использование		= Истина;
		ЭлементОтбора.ПравоеЗначение	= Параметры.Отбор.Партнер;
		ЭлементОтбора.РежимОтображения	= РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
		
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		
		ЭлементОтбора.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("СуммаДокумента");
		ЭлементОтбора.ВидСравнения		= ВидСравненияКомпоновкиДанных.НеРавно;
		ЭлементОтбора.Использование		= Истина;
		ЭлементОтбора.ПравоеЗначение	= 0;
		ЭлементОтбора.РежимОтображения	= РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
	
	КонецЕсли;	

КонецПроцедуры
