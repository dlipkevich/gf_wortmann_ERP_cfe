﻿
#Область ОбработчикиСобытийФормы

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Отказ  		 		- Булево
//   СтандартнаяОбработка	- Булево
//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

	// ИнтеграцияС1СДокументооборотом
	ИнтеграцияС1СДокументооборот.ПриСозданииНаСервере(ЭтаФорма);
	// Конец ИнтеграцияС1СДокументооборотом
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		Объект.Ответственный = Пользователи.ТекущийПользователь();
		
	КонецЕсли; 
	
	ЭлектронныеПисьма.Параметры.УстановитьЗначениеПараметра("Документ", Объект.Ссылка);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   ТекущийОбъект	- Объект
//
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	ЗаказыКлиентовЗаполнитьСуммы();
	
	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);

	КонтрагентПриИзмененииНаСервере();
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   ПараметрыЗаписи - Структура
//
&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
		МодульПодключаемыеКомандыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПодключаемыеКомандыКлиент");
		МодульПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

	ЭлектронныеПисьма.Параметры.УстановитьЗначениеПараметра("Документ", Объект.Ссылка);
	
	ЗаказыКлиентовЗаполнитьСуммы();
	
	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Отказ - Булево
//
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Отказ				- Булево
//   ТекущийОбъект		- ДокументОбъект
//   ПараметрыЗаписи	- Структура
//
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// ИнтеграцияС1СДокументооборотом
	ИнтеграцияС1СДокументооборот.ПередЗаписьюНаСервере(ЭтаФорма, ТекущийОбъект, ПараметрыЗаписи);
	// Конец ИнтеграцияС1СДокументооборотом

КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   ВыбранноеЗначение	- Произваольный
//   ИсточникВыбора		- Произваольный
//
&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ТипЗнч(ВыбранноеЗначение) <> Тип("Массив") Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	Для Каждого ЭлементМассива Из ВыбранноеЗначение Цикл
		
		Если ТипЗнч(ЭлементМассива) <> Тип("ДокументСсылка.ЗаказКлиента") Тогда
			
			Продолжить;
			
		КонецЕсли;	   
		
		ОтборЗаказа = Новый Структура("ЗаказКлиента", ЭлементМассива);
		
		Если Не Объект.ЗаказыКлиентов.НайтиСтроки(ОтборЗаказа).Количество() Тогда
			
			НоваяСтрока = Объект.ЗаказыКлиентов.Добавить();
			
			НоваяСтрока.ЗаказКлиента = ЭлементМассива;
			
			ЗаказыКлиентовЗаполнитьСуммы(ЭлементМассива); 
			
		КонецЕсли;	
		
	КонецЦикла;	
	
	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);

КонецПроцедуры // } #wortmann   

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыЗаказыКлиентов

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент	- ПолеФормы
&НаКлиенте
Процедура ЗаказыКлиентовПослеУдаления(Элемент)

	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);

КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент	- ПолеФормы
&НаКлиенте
Процедура ЗаказыКлиентовЗаказКлиентаПриИзменении(Элемент = Неопределено)
	
	ТекущиеДанные = Элементы.ЗаказыКлиентов.ТекущиеДанные;  
	
	ЗаказКлиента = ТекущиеДанные.ЗаказКлиента;   
	
	ОтборЗаказов = Новый Структура("ЗаказКлиента", ЗаказКлиента);
	
	СтрокиЗаказов = Объект.ЗаказыКлиентов.НайтиСтроки(ОтборЗаказов);
	
	Если СтрокиЗаказов.Количество()>1 Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Документ " + ЗаказКлиента + " уже есть в таблице заказов покупателей");
		
		ТекущаяСтрока = Элементы.ЗаказыКлиентов.ТекущаяСтрока;
		
		Объект.ЗаказыКлиентов.НайтиПоИдентификатору(ТекущаяСтрока).ЗаказКлиента = ТекущийЗаказКлиента;
		
		Возврат;
		
	Иначе	
		
		ТекущийЗаказКлиента = ЗаказКлиента;
		
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ЗаказКлиента) Тогда
		
		ЗаказыКлиентовЗаполнитьСуммы(ЗаказКлиента); 
		
	Иначе
		
		ТекущиеДанные.Сумма		= 0;
		ТекущиеДанные.СуммаНДС	= 0;
		
	КонецЕсли;	
	
	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент	- ПолеФормы
&НаКлиенте
Процедура ЗаказыКлиентовСуммаПриИзменении(Элемент)

	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент	- ПолеФормы
&НаКлиенте
Процедура ЗаказыКлиентовСуммаНДСПриИзменении(Элемент)

	РассчитатьИтогиПоЗаказамКлиентов(ЭтотОбъект);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент	- ПолеФормы
&НаКлиенте
Процедура ЗаказыКлиентовПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.ЗаказыКлиентов.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		
		ТекущийЗаказКлиента = Неопределено;
		
	Иначе	
	
		ТекущийЗаказКлиента = ТекущиеДанные.ЗаказКлиента;
	
	КонецЕсли;
	
КонецПроцедуры // } #wortmann

#КонецОбласти

#Область ОбработчикиКомандФормы   

// СтандартныеПодсистемы.ПодключаемыеКоманды
//
// Параметры:
//
//   ПараметрыВыполнения - Произвольный
//
&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
	
КонецПроцедуры // } #wortmann

// Параметры:
//
//   ПараметрыВыполнения		- Произвольный
//   ДополнительныеПараметры	- Произвольный
//
&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
	
КонецПроцедуры // } #wortmann

// Параметры:
//
//   Команда - Строка
//
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда) 
	
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
	
КонецПроцедуры // } #wortmann

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()   
	
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);  
	
КонецПроцедуры // } #wortmann
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

// ИнтеграцияС1СДокументооборотом
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуИнтеграции(Команда)
	
	ИнтеграцияС1СДокументооборотКлиент.ВыполнитьПодключаемуюКомандуИнтеграции(Команда, ЭтаФорма, Объект);
	
КонецПроцедуры // } #wortmann
// Конец ИнтеграцияС1СДокументооборотом

&НаКлиенте
Процедура КомандаПодбор(Команда)
	
	ПараметрОтбор = Новый Структура();
	
	ПараметрОтбор.Вставить("Организация",	Объект.Организация);
	ПараметрОтбор.Вставить("Партнер",		Партнер);
	
	ПараметрыОткрытия = Новый Структура;
	
	ПараметрыОткрытия.Вставить("Отбор",					ПараметрОтбор);
	ПараметрыОткрытия.Вставить("ДляСпецификации",		Истина);
	ПараметрыОткрытия.Вставить("МножественныйВыбор",	Истина);
	
	ОткрытьФорму("Документ.ЗаказКлиента.ФормаВыбора", ПараметрыОткрытия, ЭтотОбъект);
					
КонецПроцедуры // } #wortmann

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   ЗаказКлиента	- ДокументСсылка
//
&НаСервере
Процедура ЗаказыКлиентовЗаполнитьСуммы(ЗаказКлиента = Неопределено)
	
	МассивЗаказов =  ПолучитьМассивЗаказов(ЗаказКлиента);
	
	Если Не МассивЗаказов.Количество() Тогда
		
		Возврат;
		
	КонецЕсли;	   
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	Заказы.Ссылка КАК Ссылка,
	|	ВЫБОР
	|		КОГДА СУММА(ЗаказКлиентагф_ТоварыВКоробах.Сумма) = 0
	|			ТОГДА СУММА(ВЫБОР
	|						КОГДА ЗаказКлиентаТовары.Отменено
	|							ТОГДА 0
	|						ИНАЧЕ ЗаказКлиентаТовары.СуммаСНДС
	|					КОНЕЦ)
	|		ИНАЧЕ СУММА(ЗаказКлиентагф_ТоварыВКоробах.Сумма)
	|	КОНЕЦ КАК Сумма,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА СУММА(ЗаказКлиентагф_ТоварыВКоробах.Сумма) = 0
	|				ТОГДА СУММА(ВЫБОР
	|							КОГДА ЗаказКлиентаТовары.Отменено
	|								ТОГДА 0
	|							ИНАЧЕ ЗаказКлиентаТовары.СуммаНДС
	|						КОНЕЦ)
	|			ИНАЧЕ СУММА(ЗаказКлиентагф_ТоварыВКоробах.Сумма) / (100 + МАКСИМУМ(СтавкиНДС.Ставка)) * МАКСИМУМ(СтавкиНДС.Ставка)
	|		КОНЕЦ КАК ЧИСЛО(15, 2)) КАК СуммаНДС
	|ИЗ
	|	Документ.ЗаказКлиента КАК Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтавкиНДС КАК СтавкиНДС
	|			ПО ЗаказКлиентаТовары.СтавкаНДС = СтавкиНДС.Ссылка
	|		ПО Заказы.Ссылка = ЗаказКлиентаТовары.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
	|		ПО Заказы.Ссылка = ЗаказКлиентагф_ТоварыВКоробах.Ссылка
	|ГДЕ
	|	Заказы.Ссылка В(&Заказы)
	
	|СГРУППИРОВАТЬ ПО
	|	Заказы.Ссылка";
	
	Запрос.Параметры.Вставить("Заказы", МассивЗаказов);     
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		ОтборСтрок = Новый Структура("ЗаказКлиента", Выборка.Ссылка);
		
		СтрокиЗаказов = Объект.ЗаказыКлиентов.НайтиСтроки(ОтборСтрок);
		
		Для Каждого СтрокаЗаказа Из СтрокиЗаказов Цикл 
			
			Если СтрокаЗаказа.Сумма <> Выборка.Сумма ИЛИ 
				СтрокаЗаказа.СуммаНДС <> Выборка.СуммаНДС Тогда
				
				ЗаполнитьЗначенияСвойств(СтрокаЗаказа, Выборка); 
				
				Модифицированность = Истина;
				
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   ЗаказКлиента - ДокументСсылка
//
// Возвращаемое значение:
//
//	- Массив - ЗаказКлиента в массиве
//
&НаСервере
Функция ПолучитьМассивЗаказов(ЗаказКлиента = Неопределено)
	
	МассивЗаказов = Новый Массив;

	Если ЗаказКлиента = Неопределено Тогда 
		
		Для Каждого СтрокаЗаказа Из Объект.ЗаказыКлиентов Цикл
			
			МассивЗаказов.Добавить(СтрокаЗаказа.ЗаказКлиента);
			
		КонецЦикла;	
		
	Иначе                        
		
		МассивЗаказов.Добавить(ЗаказКлиента);
		
	КонецЕсли;  
	
	Возврат МассивЗаказов;
	
КонецФункции // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Форма	- Форма
&НаКлиентеНаСервереБезКонтекста 
Процедура РассчитатьИтогиПоЗаказамКлиентов(Форма)

	Форма.ИтогСумма		= Форма.Объект.ЗаказыКлиентов.Итог("Сумма");
	Форма.ИтогСуммаНДС	= Форма.Объект.ЗаказыКлиентов.Итог("СуммаНДС");
	
КонецПроцедуры // } #wortmann	

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент				- ПолеФормы
//   ДанныеВыбора			- Произвольный
//   СтандартнаяОбработка	- Булево
//
&НаКлиенте
Процедура ЗаказыКлиентовЗаказКлиентаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрОтбор = Новый Структура();
	
	ПараметрОтбор.Вставить("Организация",	Объект.Организация);
	ПараметрОтбор.Вставить("Партнер",		Партнер);
	
	ПараметрыОткрытия = Новый Структура;
	
	ПараметрыОткрытия.Вставить("Отбор",				ПараметрОтбор);
	ПараметрыОткрытия.Вставить("ДляСпецификации",	Истина);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗаказыКлиентовОкончаниеВыбора", ЭтотОбъект, ПараметрыОткрытия);
	
	ОткрытьФорму("Документ.ЗаказКлиента.ФормаВыбора", ПараметрыОткрытия, ЭтотОбъект, , , ,
					ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	        
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Результат					- Произвольный
//   ДополнительныеПараметры	- Структура
//
&НаКлиенте
Процедура ЗаказыКлиентовОкончаниеВыбора(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		
		ТекущиеДанные = Элементы.ЗаказыКлиентов.ТекущиеДанные;  
		
		ТекущиеДанные.ЗаказКлиента = Результат;  
		
		ЗаказыКлиентовЗаказКлиентаПриИзменении();
		
	КонецЕсли;	

КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
&НаСервере
Процедура КонтрагентПриИзмененииНаСервере()
	
	Партнер = Объект.Контрагент.Партнер;
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/15
//
// Параметры:
//
//   Элемент				- ПолеФормы
//
&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	КонтрагентПриИзмененииНаСервере();
КонецПроцедуры // } #wortmann

#КонецОбласти