﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
&После("ПриОткрытии")
Процедура гф_ПриОткрытии(Отказ)
	// vvv Галфинд \ Sakovich 07.03.2024
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eedbbb98f1041d
	Если ТипЗнч(ВладелецФормы) = Тип("ФормаКлиентскогоПриложения") И
		ВладелецФормы.ИмяФормы = "Обработка.АктСверкиПоГруппеКлиентов.Форма.ФормаУправляемая" И
		УникальныйИдентификаторХранилища = ВладелецФормы.УникальныйИдентификатор Тогда
		гф_СформироватьПараметрыОтправкиАктСверкиПоГруппеКлиентов();
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 07.03.2024
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура гф_СформироватьПараметрыОтправкиАктСверкиПоГруппеКлиентов()
	МассивПредставленийДокументов = Новый Массив;
	Для каждого ЭлКоллекции Из ВладелецФормы.Объект.ПоДаннымОрганизации Цикл
		НаименованиеПартнера = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(
		ЭлКоллекции["Контрагент"], "Партнер.НаименованиеПолное");
		ПредставлениеДокумента = ЭлКоллекции["Представление"] + " " + НаименованиеПартнера;
		МассивПредставленийДокументов.Добавить(ПредставлениеДокумента); 
	КонецЦикла;
	ПараметрыВывода.ПараметрыОтправки.Тема = СтрСоединить(МассивПредставленийДокументов, Символы.ПС);
	гф_СформроватьПолучателяПоПартнеру(ВладелецФормы.Объект.Партнер);
КонецПроцедуры

&НаСервере
Процедура гф_СформроватьПолучателяПоПартнеру(Партнер)
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ПартнерыКонтактнаяИнформация.Ссылка КАК Контакт,
	|	ПартнерыКонтактнаяИнформация.АдресЭП КАК Адрес,
	|	ПартнерыКонтактнаяИнформация.Ссылка.НаименованиеПолное КАК Представление
	|ИЗ
	|	Справочник.Партнеры.КонтактнаяИнформация КАК ПартнерыКонтактнаяИнформация
	|ГДЕ
	|	ПартнерыКонтактнаяИнформация.Ссылка = &Партнер
	|	И ПартнерыКонтактнаяИнформация.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты)
	|	И ПартнерыКонтактнаяИнформация.Вид = ЗНАЧЕНИЕ(Справочник.ВидыКонтактнойИнформации.EmailПартнера)
	|";
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	//НовыйАдрес = Новый Структура;
	//Для каждого Колонка Из Результат.Колонки Цикл
	//	НовыйАдрес.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
	//КонецЦикла;
	НовыйАдрес = Выборка.Адрес;
	ПараметрыВывода.ПараметрыОтправки.Получатель = НовыйАдрес;
КонецПроцедуры

&НаСервере
&Вместо("ПоместитьТабличныеДокументыВоВременноеХранилище")
Функция гф_ПоместитьТабличныеДокументыВоВременноеХранилище(ПереданныеНастройки)
	// ++ Галфинд СадомцевСА 18.04.2024
	// Реализовал добавление печ. формы Счета при отправке по почте печ. формы Спецификации из документа Спецификация покупателя
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eefcd193bae294
	Если СтрНайти(КлючНастроек, "гф_СпецификацияПокупателя") = 0 Тогда
		Результат = ПродолжитьВызов(ПереданныеНастройки);
		Возврат Результат;
	КонецЕсли;
	Если ОбъектыПечати.Количество() <> 1 Тогда
		Результат = ПродолжитьВызов(ПереданныеНастройки);
		Возврат Результат;
	КонецЕсли;
	ДополнительныеПараметры = Неопределено;
	Параметры.ПараметрыПечати.Свойство("ДополнительныеПараметры", ДополнительныеПараметры);
	мСчетаНаОплату = гф_НайтиСчетаНаОплату();
	Если мСчетаНаОплату.Количество() = 0 Тогда
		Результат = ПродолжитьВызов(ПереданныеНастройки);
		Возврат Результат;
	КонецЕсли;
	мПечатнаяФормаСчетаНаОплату = гф_ПолучитьМакетСчетаНаОплату();
	Если Не ЗначениеЗаполнено(мПечатнаяФормаСчетаНаОплату) Тогда
		Результат = ПродолжитьВызов(ПереданныеНастройки);
		Возврат Результат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("ДополнитьКомплектВнешнимиПечатнымиФормами", Ложь);
	Если мПечатнаяФормаСчетаНаОплату = "Счет на оплату с факсимиле (подписи)" Тогда
		ДополнительныеПараметры.Вставить("ОтображатьФаксимиле", Истина);
		ДополнительныеПараметры.Вставить("ОтображатьПодписи", Истина);
	КонецЕсли;
	
	Попытка
		НомерПервойПФ = ЭтотОбъект.гф_ЧислоПечатныхФорм;
	Исключение
		НомерПервойПФ = Неопределено;
	КонецПопытки;
	Если НомерПервойПФ = Неопределено Тогда
		НовыеРеквизитыФормы = Новый Массив;
		ИмяРеквизита = "гф_ЧислоПечатныхФорм";
		РеквизитФормы = Новый РеквизитФормы(ИмяРеквизита, Новый ОписаниеТипов("Число"));
		НовыеРеквизитыФормы.Добавить(РеквизитФормы);
		ИзменитьРеквизиты(НовыеРеквизитыФормы);
	КонецЕсли;
	гф_НастройкиПФ_УстановитьФлажокПечатать();
	Для Каждого СчетНаОплату Из мСчетаНаОплату Цикл
		ЭтотОбъект.гф_ЧислоПечатныхФорм = НастройкиПечатныхФорм.Количество();
		СчетаНаОплату = Новый Массив;
		СчетаНаОплату.Добавить(СчетНаОплату);
		ПечатныеФормыСчетовНаОплату = УправлениеПечатью.СформироватьПечатныеФормы("Обработка.ПечатьСчетовНаОплату", "СчетНаОплату",
		СчетаНаОплату, ДополнительныеПараметры, Неопределено, "");
		гф_КоллекцияПФ_ЗаполнитьСинонимМакета(ПечатныеФормыСчетовНаОплату, СчетНаОплату);
		СоздатьРеквизитыИЭлементыФормыДляПечатныхФорм(ПечатныеФормыСчетовНаОплату.КоллекцияПечатныхФорм);
	КонецЦикла;
	// -- Галфинд СадомцевСА 18.04.2024
	Результат = ПродолжитьВызов(ПереданныеНастройки);
	Возврат Результат;
КонецФункции

&НаСервере
Процедура гф_НастройкиПФ_УстановитьФлажокПечатать()
	Для Каждого НастройкаПФ Из НастройкиПечатныхФорм Цикл
		Если НастройкаПФ.ИмяМакета = "СчетНаОплату" Тогда
			НастройкаПФ.Печатать = Ложь;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура гф_КоллекцияПФ_ЗаполнитьСинонимМакета(ПечатныеФормыСчетовНаОплату, СчетНаОплату)
	Для Каждого ПФ Из ПечатныеФормыСчетовНаОплату.КоллекцияПечатныхФорм Цикл
		ПФ.СинонимМакета = "Счет на оплату № " + СчетНаОплату.Номер + " от " + Формат(СчетНаОплату.Дата, "ДФ=dd.MM.yyyy"); 
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция гф_НайтиСчетаНаОплату()
	мСпецификации = ОбъектыПечати.ВыгрузитьЗначения();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	               |	СчетНаОплатуКлиенту.Ссылка КАК Ссылка
	               |ИЗ
	               |	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	               |ГДЕ
	               |	СчетНаОплатуКлиенту.гф_СпецификацияПокупателя В(&гф_СпецификацияПокупателя)";
	Запрос.УстановитьПараметр("гф_СпецификацияПокупателя", мСпецификации);
	Результат = Запрос.Выполнить();
	Возврат Результат.Выгрузить().ВыгрузитьКолонку("Ссылка");
КонецФункции

&НаСервере
Функция гф_ПолучитьМакетСчетаНаОплату()
	гф_ПечатнаяФормаСчетаДляСпецификацииПокупателя = 
		_омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение("гф_ПечатнаяФормаСчетаДляСпецификацииПокупателя");
	Если гф_ПечатнаяФормаСчетаДляСпецификацииПокупателя = Неопределено Тогда
		Возврат "";
	Иначе
		ПечатнаяФорма = гф_ПечатнаяФормаСчетаДляСпецификацииПокупателя;
		Возврат ПечатнаяФорма;
	КонецЕсли;
КонецФункции

&НаСервере
&ИзменениеИКонтроль("СоздатьРеквизитыИЭлементыФормыДляПечатныхФорм")
Процедура гф_СоздатьРеквизитыИЭлементыФормыДляПечатныхФорм(КоллекцияПечатныхФорм)

	// Создание реквизитов для табличных документов.
	НовыеРеквизитыФормы = Новый Массив; // Массив из РеквизитФормы -
	#Вставка
	// Галфинд СадомцевСА 18.04.2024
	Попытка
		НомерПервойПФ = ЭтотОбъект.гф_ЧислоПечатныхФорм;
	Исключение
		НомерПервойПФ = 0;
	КонецПопытки;
	#КонецВставки
	Для НомерПечатнойФормы = 1 По КоллекцияПечатныхФорм.Количество() Цикл
		ИмяРеквизита = "ПечатнаяФорма" + Формат(НомерПечатнойФормы,"ЧГ=0");
		#Вставка
		// Галфинд СадомцевСА 18.04.2024
		ИмяРеквизита = "ПечатнаяФорма" + Формат(НомерПечатнойФормы + НомерПервойПФ,"ЧГ=0");
		#КонецВставки
		РеквизитФормы = Новый РеквизитФормы(ИмяРеквизита, Новый ОписаниеТипов("ТабличныйДокумент"),,КоллекцияПечатныхФорм[НомерПечатнойФормы - 1].СинонимМакета);
		НовыеРеквизитыФормы.Добавить(РеквизитФормы);
	КонецЦикла;
	ИзменитьРеквизиты(НовыеРеквизитыФормы);

	// Создание страниц с табличными документами на форме.
	НомерПечатнойФормы = 0;
	ПечатьОфисныхДокументов = Ложь;
	ДобавленныеНастройкиПечатныхФорм = Новый Соответствие;
	Для Каждого РеквизитФормы Из НовыеРеквизитыФормы Цикл
		ОписаниеПечатнойФормы = КоллекцияПечатныхФорм[НомерПечатнойФормы];

		// Таблица настроек печатных форм (начало).
		НоваяНастройкаПечатнойФормы = НастройкиПечатныхФорм.Добавить();
		НоваяНастройкаПечатнойФормы.Представление = ОписаниеПечатнойФормы.СинонимМакета;
		НоваяНастройкаПечатнойФормы.Печатать = ОписаниеПечатнойФормы.Экземпляров > 0;
		НоваяНастройкаПечатнойФормы.Количество = ОписаниеПечатнойФормы.Экземпляров;
		НоваяНастройкаПечатнойФормы.ИмяМакета = ОписаниеПечатнойФормы.ИмяМакета;
		НоваяНастройкаПечатнойФормы.ПозицияПоУмолчанию = НомерПечатнойФормы;
		#Вставка
		// Галфинд СадомцевСА 18.04.2024
		НоваяНастройкаПечатнойФормы.ПозицияПоУмолчанию = НомерПечатнойФормы + НомерПервойПФ;
		#КонецВставки
		НоваяНастройкаПечатнойФормы.Название = ОписаниеПечатнойФормы.СинонимМакета;
		НоваяНастройкаПечатнойФормы.ПутьКМакету = ОписаниеПечатнойФормы.ПолныйПутьКМакету;
		НоваяНастройкаПечатнойФормы.ИмяФайлаПечатнойФормы = ОбщегоНазначения.ЗначениеВСтрокуXML(ОписаниеПечатнойФормы.ИмяФайлаПечатнойФормы);
		НоваяНастройкаПечатнойФормы.ОфисныеДокументы = ?(ПустаяСтрока(ОписаниеПечатнойФормы.ОфисныеДокументы), "", ОбщегоНазначения.ЗначениеВСтрокуXML(ОписаниеПечатнойФормы.ОфисныеДокументы));
		Если ОписаниеПечатнойФормы.ТабличныйДокумент.ВысотаТаблицы = 0 Тогда
			НоваяНастройкаПечатнойФормы.ПодписьИПечать = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ПечатьДокументовOfficeOpen",
			"ПодписьИПечать", Ложь)
		Иначе
			НоваяНастройкаПечатнойФормы.ПодписьИПечать = ЕстьПодписьИПечать(ОписаниеПечатнойФормы.ТабличныйДокумент);
		КонецЕсли;
		НоваяНастройкаПечатнойФормы.ДоступенВыводНаДругихЯзыках = ОписаниеПечатнойФормы.ДоступенВыводНаДругихЯзыках;
		Если ЗначениеЗаполнено(НоваяНастройкаПечатнойФормы.ПутьКМакету) Тогда
			Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
				МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
				НоваяНастройкаПечатнойФормы.ДоступныеЯзыки = СтрСоединить(МодульУправлениеПечатьюМультиязычность.ЯзыкиМакета(НоваяНастройкаПечатнойФормы.ПутьКМакету), ",");
			КонецЕсли;
		КонецЕсли;

		ПечатьОфисныхДокументов = ПечатьОфисныхДокументов ИЛИ НЕ ПустаяСтрока(НоваяНастройкаПечатнойФормы.ОфисныеДокументы);

		РанееДобавленнаяНастройкаПечатнойФормы = ДобавленныеНастройкиПечатныхФорм[ОписаниеПечатнойФормы.ИмяМакета];
		Если РанееДобавленнаяНастройкаПечатнойФормы = Неопределено Тогда
			// Копирование табличного документа в реквизит формы.
			ИмяРеквизита = РеквизитФормы.Имя;
			ЭтотОбъект[ИмяРеквизита] = ОписаниеПечатнойФормы.ТабличныйДокумент;

			// Создание страниц для табличных документов.
			ИмяСтраницы = "Страница" + ИмяРеквизита;
			Страница = Элементы.Добавить(ИмяСтраницы, Тип("ГруппаФормы"), Элементы.Страницы);
			Страница.Вид = ВидГруппыФормы.Страница;
			Страница.Картинка = БиблиотекаКартинок.ТабличныйДокументВставитьРазрывСтраницы;
			Страница.Заголовок = ОписаниеПечатнойФормы.СинонимМакета;
			Страница.Подсказка = ОписаниеПечатнойФормы.СинонимМакета;
			Страница.Видимость = ЭтотОбъект[ИмяРеквизита].ВысотаТаблицы > 0;

			// Создание элементов под табличные документы.
			НовыйЭлемент = Элементы.Добавить(ИмяРеквизита, Тип("ПолеФормы"), Страница);
			НовыйЭлемент.Вид = ВидПоляФормы.ПолеТабличногоДокумента;
			НовыйЭлемент.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
			НовыйЭлемент.ПутьКДанным = ИмяРеквизита;
			УстановитьПараметрыПоляТабличногоДокумента(НовыйЭлемент, ОписаниеПечатнойФормы.ТабличныйДокумент);

			// Таблица настроек печатных форм (продолжение).
			НоваяНастройкаПечатнойФормы.ИмяСтраницы = ИмяСтраницы;
			НоваяНастройкаПечатнойФормы.ИмяРеквизита = ИмяРеквизита;

			ДобавленныеНастройкиПечатныхФорм.Вставить(НоваяНастройкаПечатнойФормы.ИмяМакета, НоваяНастройкаПечатнойФормы);
		Иначе
			НоваяНастройкаПечатнойФормы.ИмяСтраницы = РанееДобавленнаяНастройкаПечатнойФормы.ИмяСтраницы;
			НоваяНастройкаПечатнойФормы.ИмяРеквизита = РанееДобавленнаяНастройкаПечатнойФормы.ИмяРеквизита;
		КонецЕсли;

		НоваяНастройкаПечатнойФормы.ТекстОшибкиФормирования = ОписаниеПечатнойФормы.ТекстОшибкиФормирования;
		НомерПечатнойФормы = НомерПечатнойФормы + 1;
	КонецЦикла;

	Если ПечатьОфисныхДокументов И НЕ ЗначениеЗаполнено(НастройкиФорматаСохранения) Тогда
		НастройкиФорматаСохранения = Новый Структура("ТипФайлаТабличногоДокумента,Представление,Расширение,Фильтр")
	КонецЕсли;

КонецПроцедуры

#КонецОбласти





