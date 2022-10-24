﻿#Если НЕ МобильныйАвтономныйСервер Тогда
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// #wortmann {
// #Монитор логиста
// Запись истории статусов ордеров
// Галфинд Окунев 2022/09/13
&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ)
	
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних.Статус КАК Статус
	               |ИЗ
	               |	РегистрСведений.гф_ИсторияСтатусовРасходныхОрдеров.СрезПоследних(, Объект = &Ссылка) КАК гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних
	               |ГДЕ
	               |	гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних.Статус = &Статус";
	
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	Запрос.Параметры.Вставить("Статус", Статус);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда 
		
		Запись = РегистрыСведений.гф_ИсторияСтатусовРасходныхОрдеров.СоздатьМенеджерЗаписи();
		
		Запись.Период			= ТекущаяДатаСеанса();
		Запись.Активность		= Истина;
		Запись.Объект			= Ссылка;
		Запись.Статус			= Статус;
		Запись.СтатусИзменил	= Пользователи.ТекущийПользователь();
		
		Запись.Записать();
		
	КонецЕсли;	
	
КонецПроцедуры // } #wortmann

// #wortmann {
// Заполнение штрихкодов упаковк из распоряжений на перемещение
// Галфинд Sakovich 2022/10/22
&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		ШтрихкодыУпаковок.Очистить();
		Распоряжения = ТоварыПоРаспоряжениям.Выгрузить();
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	Распоряжения.Распоряжение КАК Распоряжение
		|ПОМЕСТИТЬ Распоряжения
		|ИЗ
		|	&Распоряжения КАК Распоряжения
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПеремещенияШК.ШтрихкодУпаковки КАК ШтрихкодУпаковки
		|ИЗ
		|	Распоряжения КАК Распоряжения
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров.гф_ШтрихкодыУпаковок КАК ПеремещенияШК
		|		ПО Распоряжения.Распоряжение = ПеремещенияШК.Ссылка
		|ГДЕ
		|	ПеремещенияШК.Ссылка ЕСТЬ НЕ NULL");
		
		Запрос.УстановитьПараметр("Распоряжения", Распоряжения);
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				нс = ШтрихкодыУпаковок.Добавить();
				нс["ШтрихкодУпаковки"] = Выборка["ШтрихкодУпаковки"];
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры // } #wortmann

#КонецОбласти

#КонецЕсли
#КонецЕсли