﻿#Область ОбработчикиСобытийФормы 

// #wortmann {
// Условное оформление для поля документ основание
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Параметры:
// Отказ, СтандартнаяОбработка
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	ОбщегоНазначенияУТКлиентСервер.УстановитьСвойствоЭлементаФормы(
	Элементы, "ДокументОснование", "Видимость", ЗначениеЗаполнено(Объект.ДокументОснование));
	
	Если НЕ Объект.Заблокирован Тогда
	     Элементы.Исключения.Видимость=Истина;
	КонецЕсли;
	Если Объект.Исключения Тогда
		Элементы.Согласовано.Видимость = Истина;
		Элементы.ДействуетДо.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры
// } #wortmann

// #wortmann { 
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Параметры:
// ТекущийОбъект
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры
// } #wortmann

// #wortmann { 
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
// Параметры:
// ПараметрыЗаписи
&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
		МодульПодключаемыеКомандыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПодключаемыеКомандыКлиент");
		МодульПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры
// } #wortmann

// #wortmann { 
// Типовой функционал для добавления команд
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Параметры:
// Отказ
&НаКлиенте
Процедура ПриОткрытии(Отказ)

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры
// } #wortmann

#КонецОбласти

#Область ОбработчикиСобытийЭлементовСтраницыФормыОсновная 
// #wortmann {
// Условное оформление в зависимости от значения поля исключения.
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Параметры:
// Элемент
&НаКлиенте
Процедура ИсключенияПриИзменении(Элемент)
	
	ДеньВСекундах = 86400;
	
	Если Объект.Исключения Тогда
		Элементы.Согласовано.Видимость = Истина;
		Элементы.Согласовано.АвтоОтметкаНезаполненного = Истина;  
		Элементы.ДействуетДо.Видимость = Истина;
		Объект.ДействуетДо = ТекущаяДата() + ДеньВСекундах;
	Иначе
		Элементы.Согласовано.Видимость = Ложь;
		Элементы.ДействуетДо.Видимость = Ложь;
		Объект.Согласовано = "";
		Объект.ДействуетДо = Дата(1, 1, 1);
	КонецЕсли;
	
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Условное оформление в зависимости от значения поля заблокирован.
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05 
// Параметры:
// Элемент
&НаКлиенте
Процедура ЗаблокированПриИзменении(Элемент)
	Если Объект.Заблокирован=Истина Тогда
		Элементы.Исключения.Видимость=Ложь;
	Иначе
		Элементы.Исключения.Видимость=Истина;
    КонецЕсли;
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Настройка отбора в форме выбора договора контрагента
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
// Параметры:
// Элемент,ДанныеВыбора,СтандартнаяОбработка
&НаКлиенте
Процедура ДоговорКонтрагентаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка) 
	
	СтандартнаяОбработка = Ложь;   
	
	Отбор = Новый Структура;
	Отбор.Вставить("Партнер", объект.Партнер);
	Если ЗначениеЗаполнено(Объект.Организация) Тогда
	Отбор.Вставить("Организация", Объект.Организация); 
	КонецЕсли;
	ПараметрыФормы = Новый Структура("Отбор", Отбор);   
	Оповещение = Новый ОписаниеОповещения("ПеренестиВыбранныйДоговор", ЭтотОбъект);
	ОткрытьФорму("Справочник.ДоговорыКонтрагентов.ФормаВыбора", ПараметрыФормы, , , , , Оповещение); 
	
КонецПроцедуры
// } #wortmann 

// #wortmann { 
// Параметры:
// Результат,ДополнительныеПараметры
// Установка договора после выбора его значения
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05  
// Параметры:
// Результат,ДополнительныеПараметры
&НаКлиенте
Процедура ПеренестиВыбранныйДоговор(Результат, ДополнительныеПараметры) Экспорт 
	
	Если Результат <> Неопределено Тогда
		Объект.ДоговорКонтрагента = Результат;
	КонецЕсли;
	
КонецПроцедуры
// } #wortmann

// #wortmann { 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/10/24 
// Параметры:
// Элемент
&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
ПартнерПриИзмененииСервер();
КонецПроцедуры 
// } #wortmann

// #wortmann { 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/10/24 
// Параметры:
// Элемент
&НаКлиенте
Процедура ПартнерПриИзменении(Элемент)
ПартнерПриИзмененииСервер();
КонецПроцедуры
// } #wortmann

// #wortmann {  
//Заполнение контрагента и партнера
// #4.1.15
// Галфинд(Просто) Боцманова 2022/10/24  
// Параметры:
//
&НаСервере
Процедура ПартнерПриИзмененииСервер()
	ПартнерыИКонтрагенты.ЗаполнитьКонтрагентаПартнераПоУмолчанию(Объект.Партнер, Объект.Контрагент);
КонецПроцедуры
// } #wortmann 
#КонецОбласти   

#Область ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды  

// Параметры:
// ПараметрыВыполнения
&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьПереопределяемуюКомандуНаСервере(ДополнительныеПараметры) Экспорт
	
	СобытияФорм.ВыполнитьПереопределяемуюКоманду(ЭтотОбъект, ДополнительныеПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
#КонецОбласти