﻿
&НаКлиенте
Процедура Перевести(Команда)
	
	ВывестиНаСервере();
	
	Индикатор = 0;
	КоличествоСтрок = Результат.ВысотаТаблицы;
	КоличествоКолонок = Результат.ШиринаТаблицы;

	ДляПеревода.Очистить();
	
	ГраницаИндикатора = КоличествоСтрок * 2;
	
	Для Строка=1 По КоличествоСтрок Цикл
		ОбработкаПрерыванияПользователя();
		
		Индикатор = Индикатор + 1;
		процент = Окр(100 * Индикатор / ГраницаИндикатора, 0);
		Состояние("Трансляция ", процент, "Обработка таблицы источника");
		
		Для Колонка=1 По КоличествоКолонок Цикл
			ОбработкаПрерыванияПользователя();
			Текст = Результат.Область(Строка, Колонка, Строка, Колонка).Текст;
			Если Текст > "" Тогда
				новая = ДляПеревода.Добавить();
				новая.Колонка = Колонка;
				новая.Строка = Строка;
				новая.Текст = СокрЛП(Текст);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ГраницаИндикатора = КоличествоСтрок + ДляПеревода.Количество();
	
	Если ИспользоватьAPI Тогда
		
		Если ЯзыкПеревода = ПредопределенноеЗначение("Справочник.гф_ВидыЯзыков.Deutsch") Тогда
			НаправлениеПеревода = "ru-de";
		ИначеЕсли ЯзыкПеревода = ПредопределенноеЗначение("Справочник.гф_ВидыЯзыков.Français") Тогда
			НаправлениеПеревода = "ru-fr";
		Иначе
			НаправлениеПеревода = "ru-en";
		КонецЕсли;
		
		ИмяФайла = ПолучитьИмяВременногоФайла();
		Для каждого строка Из ДляПеревода Цикл
			ОбработкаПрерыванияПользователя();
			
			Индикатор = Индикатор + 1;
			процент = Окр(100 * Индикатор / ГраницаИндикатора, 0);
			Состояние("Трансляция", процент, "Обработка таблицы результата");
			
			Результат.Область(строка.Строка, строка.Колонка, строка.Строка, строка.Колонка).Текст = ПереводОнлайн(строка.Текст, НаправлениеПеревода, ИмяФайла);
			
		КонецЦикла;
	ИначеЕсли ИспользоватьСловарь Тогда
		Если не ЗначениеЗаполнено(ЯзыкПеревода) Тогда
			сообщить("Язык перевода не задан, будет использована транслитерация.");
		КонецЕсли;
		Для каждого строка Из ДляПеревода Цикл
			ОбработкаПрерыванияПользователя();
			
			Индикатор = Индикатор + 1;
			процент = Окр(100 * Индикатор / ГраницаИндикатора, 0);
			Состояние("Трансляция", процент, "Обработка таблицы результата");
			
			Результат.Область(строка.Строка, строка.Колонка, строка.Строка, строка.Колонка).Текст = Транслитерация(строка.Текст);
		КонецЦикла;	
	Иначе
		Для каждого строка Из ДляПеревода Цикл
			ОбработкаПрерыванияПользователя();
			
			Индикатор = Индикатор + 1;
			процент = Окр(100 * Индикатор / ГраницаИндикатора, 0);
			Состояние("Трансляция", процент, "Обработка таблицы результата");
			
			Результат.Область(строка.Строка, строка.Колонка, строка.Строка, строка.Колонка).Текст = Транслитерация(строка.Текст, Истина);
		КонецЦикла;
	КонецЕсли;
	
	Элементы.Панель.ТекущаяСтраница = Элементы.ГруппаРезультат;
	Состояние("");
	
КонецПроцедуры

&НаСервере
Процедура ВывестиНаСервере()

	Результат.Очистить();
	Результат.Вывести(Источник);	

КонецПроцедуры

&НаСервере
Функция ПолучитьОтвет(ИмяФайла)
	
	текст = "";
	
	Чтение = Новый ЧтениеXML;
	Чтение.ОткрытьФайл(ИмяФайла);
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента и Чтение.Имя = "text" Тогда
			
			Если Чтение.Прочитать() и Чтение.ТипУзла = ТипУзлаXML.Текст Тогда
				текст = Чтение.Значение;
				Прервать;
			КонецЕсли;
			
		КонецЕсли;		
	КонецЦикла;
	
	возврат текст;
КонецФункции // ПолучитьОтвет()

&НаСервере
Функция ПолучитьОтветОшибки(ИмяФайла)
	
	текст = "";
	
	Чтение = Новый ЧтениеXML;
	
	ФайлСуществует = ПолучениеОбновленийПрограммыКлиентСервер.ФайлСуществует(ИмяФайла);
	
	Если ФайлСуществует Тогда
		
		Чтение.ОткрытьФайл(ИмяФайла);
		Пока Чтение.Прочитать() Цикл
			
			Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента и Чтение.Имя = "Error" Тогда
				текст = Чтение.значениеАтрибута("message");
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		текст = "";	
	КонецЕсли;
	
	возврат текст;
	
КонецФункции 

&НаСервере
Функция ПереводВСловаре(Данные)
	
	Если ЗначениеЗаполнено(ЯзыкПеревода) Тогда
		запрос = новый Запрос(
		"ВЫБРАТЬ
		|	а.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств КАК а
		|ГДЕ
		|	а.Объект = &Объект
		|	И а.Язык = &Язык");
		запрос.УстановитьПараметр("Объект", Данные);
		запрос.УстановитьПараметр("Язык", ЯзыкПеревода);
		выборка = запрос.Выполнить().Выбрать();
		Если выборка.Следующий() Тогда
			возврат выборка.Значение;
		КонецЕсли;
	КонецЕсли;
	
	возврат Неопределено;
		
КонецФункции

&НаКлиенте
Функция ПереводОнлайн(Данные, НаправлениеПеревода, ИмяФайла)
	
	Если Данные = "" Тогда
		возврат "";
	КонецЕсли;
	
	ПереводДанных = ПереводВСловаре(Данные);
	
	Если ПереводДанных <> Неопределено Тогда
		возврат ПереводДанных;
	КонецЕсли;
	
	ссл = Новый ЗащищенноеСоединениеOpenSSL(Новый СертификатКлиентаWindows(СпособВыбораСертификатаWindows.Выбирать), Новый СертификатыУдостоверяющихЦентровWindows());
	сервер = новый HTTPСоединение("translate.yandex.net",,,,,, ссл);
	
	СтрокаПараметраПолучения = "api/v1.5/tr/translate?key=trnsl.1.1.20181226T125308Z.54dca3bae7d879b4.18dcda3aa231b8f440cd6afcc1fada05483d49bc&lang=" + НаправлениеПеревода + "&text=" + Данные;
	запрос = Новый HTTPЗапрос(СтрокаПараметраПолучения); 
	ответ = сервер.Получить(запрос, ИмяФайла);
	Если ответ.КодСостояния = 200 Тогда
		текст = ПолучитьОтвет(ИмяФайла);
		возврат текст;
	ИначеЕсли ответ.КодСостояния = 403 Тогда
		текст = ПолучитьОтветОшибки(ИмяФайла);
	КонецЕсли;
	Сообщить("Ошибка использования API: " + текст);
	
КонецФункции


&НаСервере
Функция Транслитерация(Данные, ТолькоТранслитерация = Ложь)
	
	Если Данные = "" Тогда
		возврат "";
	КонецЕсли;
		
	Если ТолькоТранслитерация = Ложь Тогда
	
		ПереводДанных = ПереводВСловаре(Данные);
		мСлов = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивСлов(Данные, " .");
		
		ПереводСлова = "";
		ПереводТекСлова = "";
			
		Если ПереводДанных = Неопределено и мСлов.Количество() >= 2 Тогда
			Для каждого Слово  Из мСлов Цикл
				ПереводТекСлова = ПереводВСловаре(Слово);
				Если ПереводТекСлова <> Неопределено Тогда
					ПереводСлова = ПереводСлова + " " + ПереводТекСлова;
				Иначе
					рез = Транслит(Слово);
					ПереводСлова = ПереводСлова + " " + рез;
				КонецЕсли;
			КонецЦикла;
			ПереводДанных = СокрЛП(ПереводСлова);
		ИначеЕсли ПереводДанных = Неопределено и мСлов.Количество() = 1 Тогда
			ПереводДанных = Транслит(Данные);	
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ПереводДанных) Тогда
			возврат ПереводДанных;
		КонецЕсли;
		
	Иначе	
		
		рез = Транслит(Данные);
		
		возврат рез;
	
	КонецЕсли;
	
КонецФункции // Транслитерация() 

&НаСервере
Функция Транслит(Данные)

	длина = СтрДлина(Данные);
	рез = "";
	Для а=1 По длина Цикл
		символ = сред(Данные, а, 1);
		Отбор = Новый Структура;
		Отбор.Вставить("Источник", символ);
		нашли = Перевод.НайтиСтроки(Отбор);
		
		Если нашли.Количество() = 0 Тогда
			рез = рез + символ;
		Иначе
			рез = рез + нашли[0].Перевод;
		КонецЕсли;
	КонецЦикла; 
	
	возврат рез;
	

КонецФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИспользоватьAPI = Ложь;
	
	Структура = новый Структура("а, б, в, г, д, е, ё, ж, з, и, й, к,
	|л, м, н, о, п, р, с, т, у, ф, х, ц, ч, ш,
	|щ, ъ, ы, ь, э, ю, я",
	"a", "b", "v", "g", "d", "e", "yo", "zh", "z", "i", "y",
	"k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "f", "kh", "ts", "ch",
	"sh", "sch", "''", "y", "'", "e", "yu", "ya");
	
	Для каждого строка Из Структура Цикл
		новая = Перевод.Добавить();
		новая.Источник = строка.Ключ;
		новая.Перевод = строка.Значение;
	КонецЦикла;
	
	Структура = новый Структура("А, Б, В, Г, Д, Е,
	|Ё, Ж, З, И, Й, К, Л, М, Н, О, П, Р,
	|С, Т, У, Ф, Х, Ц, Ч, Ш, Щ, Ъ, Ы, Ь, Э, Ю, Я",
	"A", "B", "V", "G", "D",
	"E", "Yo", "Zh", "Z", "I", "J", "K", "L", "M", "N", "O", "P", "R",
	"S", "T", "U", "F", "Kh", "Ts", "Ch", "Sh", "Sch", "''", "Y", "'", "E", "Yu", "Ya");
	
	Для каждого строка Из Структура Цикл
		новая = Перевод.Добавить();
		новая.Источник = строка.Ключ;
		новая.Перевод = строка.Значение;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьAPI(Команда)
	ИспользоватьAPI = не ИспользоватьAPI;
	Элементы.ФормаИспользоватьAPI.Пометка = ИспользоватьAPI;
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьСловарь(Команда)
	ИспользоватьСловарь = не ИспользоватьСловарь;
	Элементы.ФормаИспользоватьСловарь.Пометка = ИспользоватьСловарь;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.ФормаИспользоватьAPI.Пометка = ИспользоватьAPI;
	ИспользоватьСловарь = Истина;
	Элементы.ФормаИспользоватьСловарь.Пометка = ИспользоватьСловарь;
	ЯзыкПеревода = ПредопределенноеЗначение("Справочник.гф_ВидыЯзыков.English");
	Источник.Область().РазмещениеТекста = ТипРазмещенияТекстаТабличногоДокумента.Переносить;
	Результат.Область().РазмещениеТекста = ТипРазмещенияТекстаТабличногоДокумента.Переносить;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьРСПеревод(Команда)
	
	ОткрытьФорму("РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств.ФормаСписка", , ВладелецФормы);
	
КонецПроцедуры
