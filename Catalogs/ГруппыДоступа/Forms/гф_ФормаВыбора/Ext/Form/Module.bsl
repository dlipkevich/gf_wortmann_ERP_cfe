﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка) 
	Параметры.ВыборГруппИЭлементов = ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
	Элементы.Список.ВыборГруппИЭлементов = ИспользованиеГруппИЭлементов.ГруппыИЭлементы;
	Если Параметры.Свойство("ГруппаДоступа") Тогда
		
		ГруппаДоступаРодитель = Параметры.ГруппаДоступа;
		
		Если НЕ ЗначениеЗаполнено(ГруппаДоступаРодитель) Тогда
			Возврат;
		КонецЕсли;
		
		Список.УсловноеОформление.Элементы.Очистить();
		
		Элементы.Список.ТекущийРодитель = Параметры.ГруппаДоступа;
		
		ЭлементУО = Список.УсловноеОформление.Элементы.Добавить();
		ЭлементУО.Использование = Истина;
		ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
		
		ОтборГруппа = ЭлементУО.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
		ОтборГруппа.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаНе;
		
		ОтборЭлемент = ОтборГруппа.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемент.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Ссылка");
		ОтборЭлемент.ВидСравнения = ВидСравненияКомпоновкиДанных.ВИерархии;
		ОтборЭлемент.ПравоеЗначение = Параметры.ГруппаДоступа;
		
		ПолеОформления = ЭлементУО.Поля.Элементы.Добавить();
		ПолеОформления.Использование = Истина;
		ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("Наименование");
		
		ПолеОформления = ЭлементУО.Поля.Элементы.Добавить();
		ПолеОформления.Использование = Истина;
		ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("Код");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если ВыбраннаяСтрока = ГруппаДоступаРодитель Тогда
		СтандартнаяОбработка = Ложь;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Разрешено выбирать только подчиненные группы");
	КонецЕсли;
	
КонецПроцедуры
