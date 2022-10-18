﻿#Область ПрограммныйИнтерфейс

Функция ТекущийПользователь() Экспорт
	Возврат ПользователиКлиентСервер.ТекущийПользователь();
КонецФункции

Функция СообщитьОбОшибке(ТекстСообщения, Отказ = Ложь, Заголовок = "") Экспорт
	
	Отказ = Истина;
	
	#Если ВнешнееСоединение Тогда
		
		Если ЗначениеЗаполнено(Заголовок) Тогда
			ТекстСообщения = Заголовок + Символы.ПС + ТекстСообщения;
			Заголовок = "";
		КонецЕсли;
		
		ВызватьИсключение (ТекстСообщения);
		
	#Иначе
				
		Если ЗначениеЗаполнено(Заголовок) Тогда
			ОбщегоНазначенияСлужебныйКлиентСервер.СообщитьПользователю(Заголовок);
			Заголовок = "";
		КонецЕсли;
		ОбщегоНазначенияСлужебныйКлиентСервер.СообщитьПользователю(ТекстСообщения);
	#КонецЕсли
	
	Возврат Ложь;
КонецФункции

Процедура УстановитьЗначение(Реквизит, Значение) Экспорт

	Если Реквизит <> Значение Тогда
		Реквизит = Значение;
	КонецЕсли;

КонецПроцедуры

Функция ЗначениеЭлементаСтруктуры(Знач Структура, Знач Поле, Знач ЗначениеПоУмолчанию = Неопределено) Экспорт
	Перем Значение;
	
	Возврат ?(Структура.Свойство(Поле, Значение), Значение, ЗначениеПоУмолчанию);
КонецФункции

Функция ЗначениеСвойстваОбъекта(Знач Объект, Знач Поле, Знач ЗначениеПоУмолчанию = Неопределено) Экспорт
	пСтруктура = Новый Структура(Поле, ЗначениеПоУмолчанию);
	
	Попытка
		ЗаполнитьЗначенияСвойств(пСтруктура, Объект);
	Исключение
		Возврат ЗначениеПоУмолчанию;
	КонецПопытки;
	
	Возврат пСтруктура[Поле];
КонецФункции

Функция ЗначениеВМассив(Знач Значение) Экспорт
	пРезультат = Новый Массив;
	пРезультат.Добавить(Значение);
	
	Возврат пРезультат;
КонецФункции

Функция ПолучитьПрефиксИзСтроки(Знач Строка, Знач ЗначениеДляПустого = "") Экспорт
	пСтрока = СокрЛП(Строка);
	пДлина = СтрДлина(пСтрока);
	пПрефикс = "";
	НачПозиция = 48;
	КонПозиция = 57;
	
	Для Сч = 1 По пДлина Цикл
		КодСимвола = КодСимвола(пСтрока, Сч);
		Если (КодСимвола >= НачПозиция И КодСимвола <= КонПозиция) Тогда
			Прервать;
		КонецЕсли;
		пПрефикс = пПрефикс + Сред(пСтрока, Сч, 1);
	КонецЦикла;
	
	Возврат ?(пПрефикс = "", ЗначениеДляПустого, пПрефикс);
КонецФункции

Функция ПолучитьГлобальноеЗначение(Имя, ЗначениеПоУмолчанию = Неопределено, 
	ЗаменитьНеопределеноНаЗначениеПоУмолчанию = Ложь) Экспорт
	Возврат _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение(Имя, ЗначениеПоУмолчанию, ЗаменитьНеопределеноНаЗначениеПоУмолчанию);
КонецФункции

Функция ПолучитьГлобальноеЗначениеМассив(Имя, ЗначениеПоУмолчанию = Неопределено) Экспорт
	Возврат _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначениеМассив(Имя);
КонецФункции

Функция ПолучитьГлобальноеЗначениеСАвторизацией(Имя) Экспорт
	Возврат _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначениеСАвторизацией(Имя);
КонецФункции

#Если Клиент Тогда
	
Процедура ОткрытьФормуВнешнейОбработки(Знач Ссылка, Знач ВладелецФормы, Параметры = Неопределено, ЭтоОтчет = ложь, ИмяФормы = "", пРежимОткрытияОкна = "Независимый") Экспорт
	// создана на базе ОбщийМодуль.ДополнительныеОтчетыИОбработкиКлиент.ВыполнитьОткрытиеФормыОбработки()
	
	Если ТипЗнч(Ссылка) = Тип("Строка") Тогда
		пСтрук = _омОбщегоНазначенияВызовСервера.СформироватьПараметрыЗапускаВнешнейОбработки(Ссылка);
		Если пСтрук = Неопределено Тогда
			Возврат;
		КонецЕсли;
		Ссылка = пСтрук.Ссылка;
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ВызватьИсключение "Обычное приложение не поддерживается!"
	#Иначе
		ИмяОбработки = ДополнительныеОтчетыИОбработкиВызовСервера.ПодключитьВнешнююОбработку(Ссылка);
		
		Если ЭтоОтчет Тогда
			пИмяФормы = "ВнешнийОтчет." + ИмяОбработки + ".Форма";
		Иначе
			пИмяФормы = "ВнешняяОбработка." + ИмяОбработки + ".Форма";
		КонецЕсли;
		
		Если не ПустаяСтрока(ИмяФормы) Тогда
			пИмяФормы = пИмяФормы + "." + ИмяФормы;
		КонецЕсли;
		
		ОткрытьФорму(пИмяФормы, Параметры, ВладелецФормы,,,,,РежимОткрытияОкнаФормы[пРежимОткрытияОкна]);
	#КонецЕсли
КонецПроцедуры

Процедура ОткрытьФормуВыбораПоказателейОтчетов(Владелец, ВидОтчета = Неопределено, ТекущийПоказатель = Неопределено, ЗакрыватьПриВыборе = истина, МножественныйВыбор = ложь) Экспорт
	пСтрук = новый Структура;
	пСтрук.Вставить("ЗакрыватьПриВыборе", ЗакрыватьПриВыборе);
	пСтрук.Вставить("МножественныйВыбор", МножественныйВыбор);
	пСтрук.Вставить("ТекущаяСтрока", ТекущийПоказатель);
	
	пСтрук.Вставить("Отбор", новый Структура);
	пСтрук.Отбор.Вставить("Владелец", ВидОтчета);
	
	ОткрытьФорму("Справочник.ПоказателиОтчетов.Форма._ФормаВыбора", пСтрук, Владелец);
КонецПроцедуры

#КонецЕсли

#КонецОбласти