﻿ #Область ОбработчикиКомандФормы

// #wortmann {
// #Груповая установка блокировок
// Галфинд(Просто) Боцманова 2022/09/09
// Отмечает все строки
// Параметры:
// Команда
&НаКлиенте
Процедура КомандаОтметитьВсе(Команда)
	
	Для Каждого Строка Из Объект.Блокировка Цикл
		
		Строка.Флаг = Истина;	
		
	КонецЦикла;
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// #Груповая установка блокировок
// Галфинд(Просто) Боцманова 2022/09/09
// Снимает все отметки
// Параметры:
// Команда
&НаКлиенте
Процедура КомандаСнятьВсеОтметки(Команда)
	
	Для Каждого Строка Из Объект.Блокировка Цикл
		
		Строка.Флаг = Ложь;	
		
	КонецЦикла;
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// #Груповая установка блокировок
// Галфинд(Просто) Боцманова 2022/09/09
// Заполняет данными из регистра причины блокировок ,где звблокирован равно истина и на дату указанную в обработке
//
&НаСервере
Процедура ЗаполнитьЗаблокированнымиНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ПричиныБлокировокСрезПоследних.Контрагент КАК Контрагент,
		|	гф_ПричиныБлокировокСрезПоследних.Партнер КАК Партнер,
		|	гф_ПричиныБлокировокСрезПоследних.ДоговорКонтрагента КАК ДоговорКонтрагента,
		|	гф_ПричиныБлокировокСрезПоследних.ВидБлокировки КАК ВидБлокировки,
		|	гф_ПричиныБлокировокСрезПоследних.Заблокирован КАК Заблокирован,
		|	гф_ПричиныБлокировокСрезПоследних.Организация КАК Организация
		|ИЗ
		|	РегистрСведений.гф_ПричиныБлокировок.СрезПоследних(&Дата, Заблокирован = ИСТИНА) КАК гф_ПричиныБлокировокСрезПоследних"; 
	Запрос.УстановитьПараметр("Дата", КонецДня(Дата));
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	Объект.Блокировка.Загрузить(РезультатЗапроса);
КонецПроцедуры
// } #wortmann

// #wortmann {
// #Груповая установка блокировок
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// Команда
&НаКлиенте
Процедура ЗаполнитьЗаблокированными(Команда)
	ЗаполнитьЗаблокированнымиНаСервере();
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// Команда
&НаКлиенте
Процедура УстановитьЗначения(Команда) 
	
	ТекущиеДанные = Элементы.Блокировка.ТекущиеДанные; 
	
	Для Каждого стр Из Объект.Блокировка Цикл 
		
		Если стр.Флаг Тогда
		Если Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаПартнер" Тогда	
		стр.Партнер=ТекущиеДанные.Партнер; 
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаОрганизация" Тогда
		стр.Организация=ТекущиеДанные .Организация; 
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаДоговорКонтрагента" Тогда
		стр.ДоговорКонтрагента=ТекущиеДанные.ДоговорКонтрагента;
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаВидБлокировки" Тогда
		стр.ВидБлокировки=ТекущиеДанные.ВидБлокировки; 
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаЗаблокирован" Тогда
		стр.Заблокирован=ТекущиеДанные.Заблокирован;
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаИсключения" Тогда
		стр.Исключения=ТекущиеДанные.Исключения; 
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаСогласовано" Тогда
		стр.Согласовано =ТекущиеДанные.Согласовано; 
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаДействуетДо" Тогда
		стр.ДействуетДо=ТекущиеДанные.ДействуетДо;
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаОтветственный" Тогда
		стр.Ответственный=ТекущиеДанные.Ответственный;
		ИначеЕсли Элементы.Блокировка.ТекущийЭлемент.Имя="БлокировкаКомментарий" Тогда
		стр.Комментарий=ТекущиеДанные.Комментарий; 
		КонецЕсли;
	КонецЕсли; 
	
	КонецЦикла; 
КонецПроцедуры

// #wortmann {
// #Груповая установка блокировок
// Галфинд(Просто) Боцманова 2022/09/09
//
&НаСервере
Процедура ВыполнитьНаСервере()
	
	Для Каждого стр Из объект.Блокировка Цикл
		Если стр.Флаг Тогда
			ПроверкаНаУникальностьЗаписейПоПериоду(стр.Партнер,стр.Контрагент, стр.ДоговорКонтрагента, стр.ВидБлокировки,стр.Организация,стр.Заблокирован,стр.Исключения,стр.ДействуетДо); 
			Если НЕ ДокументИзменен Тогда
			Документ = Документы.гф_БлокировкаРазблокировкаОтгрузок.СоздатьДокумент(); 
			ЗаполнитьЗначенияСвойств(Документ, стр);
			Документ.Дата = Дата;
			Документ.Ответственный = Пользователи.ТекущийПользователь();
			Документ.Комментарий = "Создано обработкой Групповая установка блокировок.";
			Документ.Записать(РежимЗаписиДокумента.Проведение);   
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// #wortmann {
// #Групповое содание документов на основе текущих данных
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// Команда
&НаКлиенте
Процедура ВыполнитьОперацию(Команда)
	ВыполнитьНаСервере();
КонецПроцедуры
// } #wortmann 

// #wortmann {
// #Проверяет на уникальность по периоду у регистра,в случае нахождения,идет перезапись и вывод сообщения
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// Контрагент,ДоговорКонтрагента,ВидБлокировки
&НаСервере
Процедура ПроверкаНаУникальностьЗаписейПоПериоду(Партнер,Контрагент, ДоговорКонтрагента, ВидБлокировки,Организация,Заблокирован,Исключения,ДействуетДо)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ПричиныБлокировок.Регистратор КАК Регистратор
		|ИЗ
		|	РегистрСведений.гф_ПричиныБлокировок КАК гф_ПричиныБлокировок
		|ГДЕ
		|	НАЧАЛОПЕРИОДА(гф_ПричиныБлокировок.Период, ДЕНЬ) = &Период
		|	И гф_ПричиныБлокировок.Партнер = &Контрагент
		|	И гф_ПричиныБлокировок.ДоговорКонтрагента = &ДоговорКонтрагента
		|	И гф_ПричиныБлокировок.ВидБлокировки = &ВидБлокировки
		|	И гф_ПричиныБлокировок.Заблокирован = &Заблокирован
		|	И гф_ПричиныБлокировок.Организация = &Организация";
	
	Запрос.УстановитьПараметр("Период", Дата); 
	Запрос.УстановитьПараметр("Контрагент", Партнер); 
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ДоговорКонтрагента); 
	Запрос.УстановитьПараметр("ВидБлокировки", ВидБлокировки); 
	Запрос.УстановитьПараметр("Заблокирован", Заблокирован); 
	Запрос.УстановитьПараметр("Организация",Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		НаборЗаписей = РегистрыСведений.гф_ПричиныБлокировок.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Регистратор.Установить(Выборка.Регистратор, Истина); 
		НаборЗаписей.Прочитать();
		Если Не НаборЗаписей.Количество() = 0 Тогда 
			CуществующаяЗапись=НаборЗаписей[0];
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Внимание! По %1 %2 была запись на «%3 , которая перезаписана обработкой»",
			CуществующаяЗапись.Контрагент, CуществующаяЗапись.ДоговорКонтрагента, Дата);
			Сообщение.Сообщить();

			Документ=Выборка.Регистратор.ПолучитьОбъект(); 
			Документ.Дата = Дата;
			Документ.Контрагент = Контрагент; 
			Документ.Партнер = Партнер;
			Документ.ДоговорКонтрагента= ДоговорКонтрагента;
			Документ.Организация = Организация    ;
			Документ.ВидБлокировки = ВидБлокировки ;
			Документ.Заблокирован = Заблокирован ;
			Документ.Исключения = Исключения  ;
			Документ.ДействуетДо = ДействуетДо;
			Документ.Ответственный = Пользователи.ТекущийПользователь();
			Документ.Комментарий = "Создано обработкой Групповая установка блокировок.";   
			Документ.Записать(РежимЗаписиДокумента.Проведение);   
			ДокументИзменен = Истина; 
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// #Загрузка данных из файла
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// Команда
&НаКлиенте
Процедура ЗагрузкаДанныхИзТабличногоДокумента(Команда)
	
	ПараметрыЗагрузки = ЗагрузкаДанныхИзФайлаКлиент.ПараметрыЗагрузкиДанных();
	ПараметрыЗагрузки.ПолноеИмяТабличнойЧасти = "Обработка.гф_ГрупповаяУстановкаБлокировок.Блокировка";
	ПараметрыЗагрузки.Заголовок = НСтр("ru = 'Загрузка из файла';
										|en = 'Import from file'");
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьИзФайлаЗавершение", ЭтотОбъект);
	ЗагрузкаДанныхИзФайлаКлиент.ПоказатьФормуЗагрузки(ПараметрыЗагрузки, Оповещение);
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// #Загрузка данных из файла
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// АдресЗагруженныхДанных, ДополнительныеПараметры 
&НаКлиенте
Процедура ЗагрузитьИзФайлаЗавершение(АдресЗагруженныхДанных, ДополнительныеПараметры) Экспорт
	
	Если АдресЗагруженныхДанных = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	ЗагрузитьИзФайлаНаСервере(АдресЗагруженныхДанных);
	
КонецПроцедуры
// } #wortmann 

// #wortmann {
// #Загрузка данных из файла
// Галфинд(Просто) Боцманова 2022/09/09
// Параметры:
// АдресЗагруженныхДанных
&НаСервере
Процедура ЗагрузитьИзФайлаНаСервере(АдресЗагруженныхДанных)
	
	ЗагруженныеДанные = ПолучитьИзВременногоХранилища(АдресЗагруженныхДанных);
	
	Для каждого СтрокаТаблицы Из ЗагруженныеДанные Цикл 
	
		Если Не ЗначениеЗаполнено(СтрокаТаблицы.Партнер) Тогда 
			Продолжить;
		КонецЕсли;
	
		НоваяСтрока = Объект.Блокировка.Добавить();
		НоваяСтрока.Организация = СтрокаТаблицы.Организация; 
		НоваяСтрока.Партнер = СтрокаТаблицы.Партнер;
		НоваяСтрока.Контрагент =СтрокаТаблицы.Контрагент;
		НоваяСтрока.ДоговорКонтрагента = СтрокаТаблицы.ДоговорКонтрагента;
		НоваяСтрока.ВидБлокировки = СтрокаТаблицы.ВидБлокировки;
		НоваяСтрока.Заблокирован = СтрокаТаблицы.Заблокирован;
		НоваяСтрока.Комментарий = СтрокаТаблицы.Комментарий;
		
	КонецЦикла;
	
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Настройка отбора в форме выбора договора контрагента
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/07
// Параметры:
// Элемент, ДанныеВыбора, СтандартнаяОбработка 
&НаКлиенте
Процедура БлокировкаДоговорКонтрагентаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные=Элементы.Блокировка.ТекущиеДанные;
	
	Отбор = Новый Структура;
	Отбор.Вставить("Партнер", ТекущиеДанные.Партнер);
	Если ЗначениеЗаполнено(ТекущиеДанные.Организация) Тогда
	Отбор.Вставить("Организация", ТекущиеДанные.Организация); 
	КонецЕсли;
	ПараметрыФормы = Новый Структура("Отбор", Отбор);   
	Оповещение = Новый ОписаниеОповещения("ПеренестиВыбранныйДоговор", ЭтотОбъект);
	ОткрытьФорму("Справочник.ДоговорыКонтрагентов.ФормаВыбора", ПараметрыФормы, , , , , Оповещение); 
	
КонецПроцедуры

// } #wortmann   
// #wortmann { 
// Установка договора после выбора его значения
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/07 
// Параметры:
// Результат,ДополнительныеПараметры
&НаКлиенте
Процедура ПеренестиВыбранныйДоговор(Результат, ДополнительныеПараметры) Экспорт 
	
	ТекущиеДанные=Элементы.Блокировка.ТекущиеДанные;
	
	Если Результат <> Неопределено Тогда
		ТекущиеДанные.ДоговорКонтрагента = Результат;
	КонецЕсли;
	
КонецПроцедуры

// } #wortmann   
// #wortmann { 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/10/03 
// Параметры:
// Элементы
&НаКлиенте
Процедура БлокировкаИсключенияПриИзменении(Элемент) 
	ТекущиеДанные=Элементы.Блокировка.ТекущиеДанные;
	Если ТекущиеДанные.Исключения Тогда
		ТекущиеДанные.Заблокирован=Ложь; 
	КонецЕсли; 
КонецПроцедуры  
// } #wortmann

// } #wortmann   
// #wortmann { 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/10/03 
// Параметры:
// Элементы
&НаКлиенте
Процедура БлокировкаЗаблокированПриИзменении(Элемент)
	ТекущиеДанные=Элементы.Блокировка.ТекущиеДанные;
	Если ТекущиеДанные.Заблокирован Тогда
		ТекущиеДанные.Исключения=Ложь;
	КонецЕсли;
КонецПроцедуры
// } #wortmann

#КонецОбласти  