﻿
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 17.08.2011
//
Процедура ДобавитьОбъектДляПеревода(Объект) Экспорт
	
	Если Объект = "" Тогда Возврат КонецЕсли;
	
	ОбъектБокс = ПолучитьСлужебныйКонтейнер(Объект);
	
	Если ОбъектБокс.ЭтоДокумент Тогда
		
		ИмяМетаданных = ОбъектБокс.Объект.Метаданные().Синоним;
		
		Если _ОбъектыПеревода.Найти(ИмяМетаданных) = Неопределено Тогда
		
			_ОбъектыПеревода.Добавить(ИмяМетаданных);
			
		КонецЕсли;		
		
		Если _ОбъектыПеревода.Найти("от") = Неопределено Тогда
		
			_ОбъектыПеревода.Добавить("от");
			
		КонецЕсли;	
	
	Иначе
		
		Если _ОбъектыПеревода.Найти(ОбъектБокс.Объект) = Неопределено Тогда
		
			_ОбъектыПеревода.Добавить(ОбъектБокс.Объект);
			
		КонецЕсли;

	КонецЕсли;
		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 16.08.2011
//
Процедура ДобавитьСловаИзСтрокиДляПеревода(ИсходнаяСтрока) Экспорт
	
	МультиСтрока = СтрЗаменить(ИсходнаяСтрока, " ", Символы.ПС);
	
	СтрокаДляПеревода = "";
	
	Для Индекс = 1 По СтрЧислоСтрок(МультиСтрока) Цикл
			
		Подстрока = СокрЛП(СтрПолучитьСтроку(МультиСтрока, Индекс));
		ДлинаПодстроки = СтрДлина(Подстрока);
		
		ПереводитьПодстроку = Истина;
		
		Для Инд = 1 По ДлинаПодстроки Цикл
			
			КС = КодСимвола(Сред(Подстрока, Инд, 1));	
				
			Если (КС >= 48) И (КС <= 57) Тогда

				ДобавитьОбъектДляПеревода(СтрокаДляПеревода);
				ПереводитьПодстроку = Ложь;
				СтрокаДляПеревода = "";
				Прервать;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ПереводитьПодстроку Тогда
			
			СтрокаДляПеревода = СокрЛП(СтрокаДляПеревода + ?(СтрокаДляПеревода = "", "", " ") + Подстрока);	
			
		КонецЕсли;
		
	КонецЦикла;
	
	ДобавитьОбъектДляПеревода(СтрокаДляПеревода);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 27.07.2011
//
Функция ЕстьОбъектыБезПеревода(ВыводитьСообщение = Ложь) Экспорт
	
	СтрокиБезПереводов = Объекты.НайтиСтроки(Новый Структура("Перевод", ""));
	
	Если ВыводитьСообщение Тогда
		
		Для Каждого СтрокаБезПеревода Из СтрокиБезПереводов Цикл
			
			Сообщить("Отсутствует перевод для объекта " + СтрокаБезПеревода.Наименование + "!", СтатусСообщения.Важное);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат (СтрокиБезПереводов.Количество() <> 0);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 20.07.2011
//
Процедура ИнициализироватьСписокОбъектовДляПеревода() Экспорт
	
	_ОбъектыПеревода = Новый Массив;
	Объекты.Очистить();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 12.08.2011
//
Функция НазваниеОбъекта(ОбъектБокс) Экспорт
	
	Если ОбъектБокс.ЭтоСтрока Тогда
		
		Возврат ОбъектБокс.ИсходныйОбъект;
		
	Иначе
		
		Попытка
			
			Возврат ОбъектБокс.Объект.Наименование;
			
		Исключение
			
			Возврат ?(ОбъектБокс.Объект = Неопределено, "", Строка(ОбъектБокс.Объект.Ссылка));
			
		КонецПопытки;
		
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 12.08.2011
//
Функция ПолучитьПереводОбъекта(Объект, Язык) Экспорт
	
	ОбъектБокс = ПолучитьСлужебныйКонтейнер(Объект);
	ПравилоПреобразования = ПолучитьПравилоПреобразованияРегистраСимволовДляОбъекта(ОбъектБокс);
	
	Значение = ?
	(
		ОбъектБокс.ЭтоДокумент,
		ПолучитьПереводПредставленияДокумента(ОбъектБокс.Объект, Язык),
		РегистрыСведений.RC_Переводы.Получить(Новый Структура("Объект, Язык", ОбъектБокс.Объект, Язык)).Значение
	);
	Возврат ПреобразоватьЗначениеПоПравилуРегистраСимволов(?(ПустаяСтрока(Значение), НазваниеОбъекта(ОбъектБокс), Значение) , ПравилоПреобразования);
	 	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 16.08.2011
//
Функция ПолучитьПереводПроизвольнойСтроки(ИсходнаяСтрока, Язык, ВерхнийРегистр = Ложь) Экспорт
	
	СтрокаРезультат = "";
	СтрокаДляПеревода = "";
	
	МультиСтрока = СтрЗаменить(ИсходнаяСтрока, " ", Символы.ПС);
	
	Для Индекс = 1 По СтрЧислоСтрок(МультиСтрока) Цикл
			
		Подстрока = СокрЛП(СтрПолучитьСтроку(МультиСтрока, Индекс));
		ДлинаПодстроки = СтрДлина(Подстрока);
		
		ФормироватьПодстроку = Истина;
			
		Для Инд = 1 По ДлинаПодстроки Цикл
				
			КС = КодСимвола(Сред(Подстрока, Инд, 1));	
				
			Если (КС >= 48) И (КС <= 57) Тогда
				
        СтрокаРезультат = СокрЛП(СтрокаРезультат + ?(СтрокаРезультат = "", "" , " ") + ?(СтрокаДляПеревода = "", "", ПолучитьПереводОбъекта(СтрокаДляПеревода, Язык) + " " + Подстрока));
				ФормироватьПодстроку = Ложь;
				СтрокаДляПеревода = "";
				Прервать;
				
			КонецЕсли;
						
		КонецЦикла;
			
		Если ФормироватьПодстроку Тогда
			
			СтрокаДляПеревода = СокрЛП(СтрокаДляПеревода + ?(СтрокаДляПеревода = "", "", " ") + Подстрока);	
			
		КонецЕсли;

	КонецЦикла;

	СтрокаРезультат = СокрЛП(СтрокаРезультат + ?(СтрокаРезультат = "", "" , " ") + ПолучитьПереводОбъекта(СтрокаДляПеревода, Язык));
	
	Возврат СтрокаРезультат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 18.08.2011
//
Функция ПолучитьСлужебныйКонтейнер(ПараметрОбъект) Экспорт
	
	Объект = ?(ПараметрОбъект = Неопределено, "", ПараметрОбъект);
	
	ЭтоСтрока = (ТипЗнч(Объект) = Тип("Строка"));
	
	ЭтоДокумент = ?(ЭтоСтрока, Ложь, Лев(Объект.Метаданные().ПолноеИмя(), 8) = "Документ");
	
	Возврат Новый Структура("ИсходныйОбъект, Объект, ЭтоСтрока, ЭтоДокумент", Объект, ?(ЭтоСтрока, НРег(Объект), Объект), ЭтоСтрока, ЭтоДокумент);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 22.07.2011
//
&НаКлиенте
Процедура ПроверитьДобавитьПереводОбъектов(ОбъектыПеревода = Неопределено, ЯзыкПеревода, РежимДобавлениеОбъектов = Истина, ЗадаватьВопрос = Истина, АктивизироватьЕслиВсеПереведено = Ложь) Экспорт
	
	Если ОбъектыПеревода = Неопределено Тогда ОбъектыПеревода = _ОбъектыПеревода КонецЕсли;
	
	Для Каждого Объект Из ОбъектыПеревода Цикл
		
		ОбъектБокс = ПолучитьСлужебныйКонтейнер(Объект);
		
		СтрокаОбъекты = Объекты.Добавить();
		СтрокаОбъекты.Объект = ОбъектБокс.ИсходныйОбъект;
		СтрокаОбъекты.Наименование = НазваниеОбъекта(ОбъектБокс);
		
		Если Не ОбъектБокс.ЭтоСтрока Тогда
			
			СтрокаОбъекты.ТипОбъекта = ОбъектБокс.Объект.Метаданные().ПолноеИмя()
			
		Иначе
			
			СтрокаОбъекты.ТипОбъекта = "Строка";
			
		КонецЕсли;
		
	КонецЦикла;
	
	Запрос = Новый Запрос
	(
		"ВЫБРАТЬ
		| Объект,
		|	Значение
		|ИЗ РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств
		|ГДЕ Объект В (&Объекты) И Язык = &Язык"
	);
	Запрос.УстановитьПараметр("Объекты", ОбъектыПеревода);
	Запрос.УстановитьПараметр("Язык", ЯзыкПеревода);

	ТаблицаПереводов = Запрос.Выполнить().Выгрузить();
	
	// проверка, все ли переводы есть
	Для Каждого СтрокаОбъекты Из Объекты Цикл
		
		СтрокаТаблицыПереводов = ТаблицаПереводов.Найти(СтрокаОбъекты.Объект, "Объект");
		
		Если СтрокаТаблицыПереводов <> Неопределено Тогда
			
			СтрокаОбъекты.Перевод = СтрокаТаблицыПереводов.Значение;				
						
		КонецЕсли;
		
	КонецЦикла;
	
	ВключитьОкноПеревода = РежимДобавлениеОбъектов И ЕстьОбъектыБезПеревода();
	
	Если ВключитьОкноПеревода И ЗадаватьВопрос Тогда
			
		ВключитьОкноПеревода = (Вопрос("Обнаружены объекты, не имееющие перевода! Включить режим перевода объектов?", РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да, "Подсистема перевода") = КодВозвратаДиалога.Да);
		
	КонецЕсли;
	
	Если ВключитьОкноПеревода Или АктивизироватьЕслиВсеПереведено Тогда
		
		ФормаПеревода = ПолучитьФорму("ФормаПереводаОбъектов");
		ФормаПеревода.ЯзыкПеревода = ЯзыкПеревода;
		ФормаПеревода.ТолькоБезПеревода = Истина;
		ФормаПеревода.Открыть();
		
	КонецЕсли;		
	
КонецПроцедуры



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Реализация
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 18.08.2011
//
Функция ПолучитьПереводПредставленияДокумента(Объект, Язык)
	
	Возврат ПолучитьПереводОбъекта(Объект.Метаданные().Синоним, Язык) + " " + Объект.Номер + " " + ПолучитьПереводОбъекта("от", Язык) + " " + Объект.Дата;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 18.08.2011
//
Функция ПолучитьПравилоПреобразованияРегистраСимволовДляОбъекта(ОбъектБокс) 
	
	// для объектов ссылочного типа правило вычисляется по наименованию объекта
	Если Не ОбъектБокс.ЭтоСтрока Тогда 
		
		Возврат ?
		(
			ОбъектБокс.ЭтоДокумент,
			Перечисления.RC_ПравилаПреобразованияСимволовСтрок.ТРег, 
			ПолучитьПравилоПреобразованияРегистраСимволовДляОбъекта
			(
				ПолучитьСлужебныйКонтейнер(ОбъектБокс.Объект.Наименование)
			)
		); 
		
	КонецЕсли;

	Если ОбъектБокс.ИсходныйОбъект = ОбъектБокс.Объект Тогда Возврат Перечисления.RC_ПравилаПреобразованияСимволовСтрок.НРег КонецЕсли;
	Если ВРег(ОбъектБокс.ИсходныйОбъект) = ОбъектБокс.ИсходныйОбъект Тогда Возврат Перечисления.RC_ПравилаПреобразованияСимволовСтрок.ВРег КонецЕсли;
	Возврат Перечисления.RC_ПравилаПреобразованияСимволовСтрок.ТРег;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 16.08.2011
//
Функция ПреобразоватьЗначениеПоПравилуРегистраСимволов(Значение, Правило)
	
	Если Правило = Перечисления.RC_ПравилаПреобразованияСимволовСтрок.ВРег Тогда Возврат ВРег(Значение) КонецЕсли;
	Если Правило = Перечисления.RC_ПравилаПреобразованияСимволовСтрок.ТРег Тогда Возврат ВРег(Лев(Значение, 1)) + Сред(Значение, 2) КонецЕсли;
	Если Правило = Перечисления.RC_ПравилаПреобразованияСимволовСтрок.НРег Тогда Возврат НРег(Значение) КонецЕсли;
			
КонецФункции


_ОбъектыПеревода = Новый Массив;