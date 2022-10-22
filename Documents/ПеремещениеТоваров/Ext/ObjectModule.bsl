﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	// vvv Галфинд \ Sakovich 22.10.2022
	//иначе не изменить даже с помошью СДР
	Если Не ОбменДанными.Загрузка Тогда
	// ^^^ Галфинд \ Sakovich 22.10.2022 
		
		// #wortmann {
		// #5.2.08
		// ID запрет ручного изменения документа, при наличии свойства "ДокументОснование"
		// Галфинд Volkov 2022/08/23
		Если Не ЭтотОбъект.ДополнительныеСвойства.Свойство("ДокументОснование") И ЗначениеЗаполнено(ЭтотОбъект.ДокументОснование) Тогда
			Отказ = Истина;
			ТекстСообщения = СтрШаблон(НСтр("ru = 'Данный документ не доступен для ручного изменения. Введен на основании %1.'"), ЭтотОбъект.ДокументОснование);
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект.ДокументОснование, , , Отказ);
		КонецЕсли;
		// } #wortmann
		
	// vvv Галфинд \ Sakovich 22.10.2022	
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 22.10.2022 
	
	// #wortmann {
	// При проведении необходимо перезаполнять тч "гф_ШтрихкодыУпаковок"
	// Галфинд Sakovich 2022/10/22
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		гф_ШтрихкодыУпаковок.Очистить();
		
		Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	УпЛисты.УпаковочныйЛист КАК УпЛист
		|ПОМЕСТИТЬ УпЛисты
		|ИЗ
		|	&ТоварыВКоробах КАК УпЛисты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ Различные
		|	Штрихкоды.Ссылка КАК ШтрихкодУпаковки
		|ИЗ
		|	УпЛисты КАК УпЛисты
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК Штрихкоды
		|		ПО УпЛисты.УпЛист.Код = Штрихкоды.ЗначениеШтрихкода
		|Где Штрихкоды.Ссылка  ЕСТЬ НЕ NULL");
		Запрос.УстановитьПараметр("ТоварыВКоробах", гф_ТоварыВКоробах);
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				нс = гф_ШтрихкодыУпаковок.Добавить();
				нс["ШтрихкодУпаковки"] = Выборка["ШтрихкодУпаковки"];
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли